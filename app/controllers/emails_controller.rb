class EmailsController < ApplicationController
  def new
  end

  def create
    @emails  = params[:emails].split(/[\s,]+/).uniq
    @subject = params[:subject]
    @body    = params[:body]
    @resume  = params[:resume]

    # Save resume temporarily
    resume_path = Rails.root.join("tmp", @resume.original_filename)
    File.open(resume_path, "wb") { |f| f.write(@resume.read) }

    session[:email_data] = {
      emails: @emails,
      subject: @subject,
      body: @body,
      resume_path: resume_path.to_s
    }

    render :preview
  end

  def show
    data = session[:email_data]

    data[:emails].each_with_index do |email, index|
      log = EmailLog.create!(
        email: email,
        subject: data[:subject],
        status: "pending"
      )

      SendResumeJob.set(wait: index.minutes).perform_later(
        log.id,
        email,
        data[:subject],
        data[:body],
        data[:resume_path]
      )
    end

    session.delete(:email_data)

    redirect_to root_path, notice: "Emails scheduled successfully!"
  end
end
