class SendResumeJob < ApplicationJob
  queue_as :default

  def perform(log_id, resume_path, subject, body, resume_filename)
    log = EmailLog.find(log_id)
    setting = log.user&.setting

    HrMailer
      .send_resume(
        email: log.email,
        subject: subject,
        body: body,
        resume_path: resume_path,
        resume_filename: resume_filename,
        setting: setting
      )
      .deliver_now

    log.update!(status: "sent", sent_at: Time.now)
  rescue => e
    log.update!(status: "failed")
    Rails.logger.error e.full_message
  end
end
