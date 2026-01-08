class SendResumeJob < ApplicationJob
  queue_as :default

  def perform(email_log_id, email, subject, body, resume_path)
    email_log = EmailLog.find(email_log_id)

    resume = File.open(resume_path)

    HrMailer.send_resume(email, subject, body, resume).deliver_now

    email_log.update!(
      status: "sent",
      sent_at: Time.current
    )
  rescue => e
    email_log.update!(status: "failed")
    Rails.logger.error e.message
  end
end
