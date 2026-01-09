require "securerandom"

class EmailsController < ApplicationController
  def new
  end

  def create
    @emails  = params[:emails].split(/[\s,]+/).map(&:strip).reject(&:empty?).uniq
    @subject = params[:subject]
    @body    = params[:body]
    @resume  = params[:resume]

    token = session[:email_data_key]
    existing_data = Rails.cache.read("email_form_#{token}") if token.present?

    if @resume.blank? && existing_data.present?
      resume_path = existing_data["resume_path"]
      resume_filename = existing_data["resume_filename"]
    elsif @resume.present?
      allowed_types = %w[
        application/pdf
        application/msword
        application/vnd.openxmlformats-officedocument.wordprocessingml.document
      ]

      unless allowed_types.include?(@resume.content_type)
        flash[:alert] = "Resume must be PDF, DOC, or DOCX"
        return render :new, status: :unprocessable_entity
      end

      if @resume.size > 10.megabytes
        flash[:alert] = "Resume must be less than 10MB"
        return render :new, status: :unprocessable_entity
      end

      # 🔐 Generate a SAFE filename (important)
      original_name = @resume.original_filename
      extension     = File.extname(original_name)
      safe_name     = SecureRandom.hex(16) + extension

      resume_path = Rails.root.join("tmp", safe_name)

      File.open(resume_path, "wb") do |file|
        file.write(@resume.read)
      end

      # 🔐 Keep original filename ONLY for display
      resume_filename = original_name
    else
      flash[:alert] = "Resume is required"
      return render :new, status: :unprocessable_entity
    end

    if @emails.blank? || @subject.blank? || @body.blank?
      flash[:alert] = "Emails, subject and body are required"
      return render :new, status: :unprocessable_entity
    end

    token = SecureRandom.hex(16)

    Rails.cache.write(
      "email_form_#{token}",
      {
        "emails" => @emails,
        "subject" => @subject,
        "body" => @body,
        "resume_path" => resume_path.to_s,
        "resume_filename" => resume_filename
      },
      expires_in: 30.minutes
    )

    session[:email_data_key] = token
    redirect_to confirm_emails_path
  end

  def confirm
    token = session[:email_data_key]
    data = Rails.cache.read("email_form_#{token}") if token.present?
    return redirect_to new_email_path if data.blank?

    @emails = data["emails"]
    @subject = data["subject"]
    @body = data["body"]
    @resume_filename = data["resume_filename"]
  end

  def edit
    token = session[:email_data_key]
    data = Rails.cache.read("email_form_#{token}") if token.present?
    return redirect_to new_email_path if data.blank?

    @emails = data["emails"].join("\n")
    @subject = data["subject"]
    @body = data["body"]
    @resume_filename = data["resume_filename"]
    @editing = true
    render :new
  end

  def send_emails
    token = session[:email_data_key]
    data = Rails.cache.read("email_form_#{token}") if token.present?
    return redirect_to new_email_path if data.blank?

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
        data["body"]
      )
    end

    Rails.cache.delete("email_form_#{token}") if token.present?
    session.delete(:email_data_key)

    redirect_to email_logs_path, notice: "Emails scheduled successfully!"
  end
end
