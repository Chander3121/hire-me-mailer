require "securerandom"

class EmailsController < ApplicationController
  ALLOWED_CONTENT_TYPES = {
    "application/pdf" => ".pdf",
    "application/msword" => ".doc",
    "application/vnd.openxmlformats-officedocument.wordprocessingml.document" => ".docx"
  }.freeze

  MAX_RESUME_SIZE = 10.megabytes

  def new; end

  def create
    extract_form_params

    existing_data = load_cached_data

    if @resume.blank? && existing_data.present?
      reuse_cached_resume(existing_data)
    elsif @resume.present?
      process_new_resume!
    else
      return render_error("Resume is required")
    end

    return render_error("Emails, subject and body are required") if invalid_form_data?

    cache_form_data!
    redirect_to confirm_emails_path
  end

  def confirm
    data = load_cached_data
    return redirect_to new_email_path if data.blank?

    assign_confirm_vars(data)
  end

  def edit
    data = load_cached_data
    return redirect_to new_email_path if data.blank?

    assign_edit_vars(data)
    render :new
  end

  def send_emails
    data = load_cached_data
    return redirect_to new_email_path if data.blank?

    enqueue_emails(data)
    cleanup_session

    redirect_to email_logs_path, notice: "Emails scheduled successfully!"
  end

  private

  # Form / Params
  def extract_form_params
    @emails  = params[:emails].to_s.split(/[\s,]+/).map(&:strip).reject(&:empty?).uniq
    @subject = params[:subject]
    @body    = params[:body]
    @resume  = params[:resume]
  end

  def invalid_form_data?
    @emails.blank? || @subject.blank? || @body.blank?
  end

  # Resume Handling (SECURE)
  def process_new_resume!
    extension = ALLOWED_CONTENT_TYPES[@resume.content_type]
    return render_error("Resume must be PDF, DOC, or DOCX") unless extension
    return render_error("Resume must be less than 10MB") if @resume.size > MAX_RESUME_SIZE

    filename = "#{SecureRandom.hex(16)}#{extension}"
    @resume_path = Rails.root.join("tmp", filename)

    File.open(@resume_path, "wb") { |file| file.write(@resume.read) }

    # ✅ SAFE: used only for email attachment name
    @resume_filename = @resume.original_filename
  end

  def reuse_cached_resume(data)
    @resume_path = data["resume_path"]
    @resume_filename = data["resume_filename"]
  end

  # Cache / Session
  def cache_form_data!
    token = SecureRandom.hex(16)

    Rails.cache.write(
      cache_key(token),
      {
        "emails" => @emails,
        "subject" => @subject,
        "body" => @body,
        "resume_path" => @resume_path.to_s,
        "resume_filename" => @resume_filename
      },
      expires_in: 30.minutes
    )

    session[:email_data_key] = token
  end

  def load_cached_data
    token = session[:email_data_key]
    Rails.cache.read(cache_key(token)) if token.present?
  end

  def cache_key(token)
    "email_form_#{token}"
  end

  def cleanup_session
    token = session[:email_data_key]
    Rails.cache.delete(cache_key(token)) if token.present?
    session.delete(:email_data_key)
  end

  # Assignments
  def assign_confirm_vars(data)
    @emails = data["emails"]
    @subject = data["subject"]
    @body = data["body"]
    @resume_filename = data["resume_filename"]
  end

  def assign_edit_vars(data)
    @emails = data["emails"].join("\n")
    @subject = data["subject"]
    @body = data["body"]
    @resume_filename = data["resume_filename"]
    @editing = true
  end

  # Jobs
  def enqueue_emails(data)
    data["emails"].each_with_index do |email, index|
      log = EmailLog.create!(
        email: email,
        subject: data["subject"],
        status: "pending"
      )

      SendResumeJob.set(wait: index.minutes).perform_later(
        log.id,
        data["resume_path"],
        data["subject"],
        data["body"],
        data["resume_filename"]
      )
    end
  end

  # Errors
  def render_error(message)
    flash[:alert] = message
    render :new, status: :unprocessable_entity
  end
end
