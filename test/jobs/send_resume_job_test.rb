require "test_helper"

class SendResumeJobTest < ActiveJob::TestCase
  include ActionMailer::TestHelper

  setup do
    @email_log = EmailLog.create!(
      email: "hr@company.com",
      subject: "Test Subject",
      status: "pending"
    )
    @resume_path = fixture_file_upload("resume.pdf", "application/pdf").path
  end

  test "should enqueue job successfully" do
    assert_enqueued_with(job: SendResumeJob) do
      SendResumeJob.perform_later(@email_log.id, @resume_path, "Test", "<p>Body</p>")
    end
  end

  test "should perform job and send email" do
    assert_emails 1 do
      SendResumeJob.perform_now(
        @email_log.id,
        @resume_path,
        "Test Subject",
        "<p>Application for role</p>"
      )
    end
  end

  test "should update email log status to sent" do
    SendResumeJob.perform_now(
      @email_log.id,
      @resume_path,
      "Test Subject",
      "<p>Application</p>"
    )

    @email_log.reload
    assert_equal "sent", @email_log.status
  end

  test "should set sent_at timestamp" do
    assert_nil @email_log.sent_at

    SendResumeJob.perform_now(
      @email_log.id,
      @resume_path,
      "Test Subject",
      "<p>Application</p>"
    )

    @email_log.reload
    assert_not_nil @email_log.sent_at
  end

  test "should send email to correct recipient" do
    SendResumeJob.perform_now(
      @email_log.id,
      @resume_path,
      "Test Subject",
      "<p>Application</p>"
    )

    email = ActionMailer::Base.deliveries.last
    assert_equal [ "hr@company.com" ], email.to
  end

  test "should include subject in email" do
    SendResumeJob.perform_now(
      @email_log.id,
      @resume_path,
      "Senior Position",
      "<p>Application</p>"
    )

    email = ActionMailer::Base.deliveries.last
    assert_equal "Senior Position", email.subject
  end

  test "should include body in email" do
    body = "<p>I am interested</p>"
    SendResumeJob.perform_now(
      @email_log.id,
      @resume_path,
      "Test",
      body
    )

    email = ActionMailer::Base.deliveries.last
    assert_includes email.body.encoded, "I am interested"
  end

  test "should attach resume file" do
    SendResumeJob.perform_now(
      @email_log.id,
      @resume_path,
      "Test",
      "<p>Application</p>"
    )

    email = ActionMailer::Base.deliveries.last
    assert email.attachments.any? { |att| att.filename.include?("resume") }
  end

  test "should process multiple jobs" do
    email_log_2 = EmailLog.create!(
      email: "hr2@company.com",
      subject: "Test",
      status: "pending"
    )

    assert_enqueued_jobs(2) do
      SendResumeJob.perform_later(@email_log.id, @resume_path, "Test", "<p>Body</p>")
      SendResumeJob.perform_later(email_log_2.id, @resume_path, "Test", "<p>Body</p>")
    end
  end

  test "should preserve email log after sending" do
    SendResumeJob.perform_now(
      @email_log.id,
      @resume_path,
      "Test",
      "<p>Application</p>"
    )

    log = EmailLog.find(@email_log.id)
    assert_equal "hr@company.com", log.email
    assert_equal "Test Subject", log.subject
  end
end
