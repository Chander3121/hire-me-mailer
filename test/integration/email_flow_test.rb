require "test_helper"

class EmailFlowTest < ActionDispatch::IntegrationTest
  setup do
    @resume_file = fixture_file_upload('resume.pdf', 'application/pdf')
    ActionMailer::Base.deliveries.clear
  end

  test "complete flow: create form, confirm, and send emails" do
    # Step 1: Get form page
    get new_email_path
    assert_response :success

    # Step 2: Submit form
    post emails_path, params: {
      emails: "hr1@company.com, hr2@company.com",
      subject: "Senior Rails Developer",
      body: "<p>I'm excited about this opportunity</p>",
      resume: @resume_file
    }
    assert_redirected_to confirm_emails_path
    token = session[:email_data_key]
    assert_not_nil token

    # Step 3: Verify cache storage
    cached_data = Rails.cache.read("email_form_#{token}")
    assert_equal ["hr1@company.com", "hr2@company.com"], cached_data["emails"]
    assert_equal "Senior Rails Developer", cached_data["subject"]

    # Step 4: Get confirm page
    get confirm_emails_path
    assert_response :success

    # Step 5: Send emails
    assert_difference('EmailLog.count', 2) do
      post send_emails_emails_path
    end

    # Step 6: Verify emails are queued
    assert_enqueued_jobs(2, only: SendResumeJob)

    # Step 7: Verify email logs are pending
    logs = EmailLog.where(email: ["hr1@company.com", "hr2@company.com"])
    assert logs.all? { |log| log.status == 'pending' }

    # Step 8: Verify redirect
    assert_redirected_to email_logs_path

    # Step 9: Verify session is cleared
    reset_session
    assert_nil session[:email_data_key]
  end

  test "complete flow with edit functionality" do
    # Create initial form
    post emails_path, params: {
      emails: "hr@company.com",
      subject: "Original Subject",
      body: "<p>Original body</p>",
      resume: @resume_file
    }
    assert_redirected_to confirm_emails_path

    # View confirm page
    get confirm_emails_path
    assert_response :success

    # Go to edit
    get edit_emails_path
    assert_response :success

    # Submit edit (change subject, keep resume)
    post emails_path, params: {
      emails: "hr@company.com",
      subject: "Updated Subject",
      body: "<p>Updated body</p>"
    }
    assert_redirected_to confirm_emails_path

    # Verify updated data
    token = session[:email_data_key]
    cached_data = Rails.cache.read("email_form_#{token}")
    assert_equal "Updated Subject", cached_data["subject"]

    # Send
    assert_difference('EmailLog.count', 1) do
      post send_emails_emails_path
    end
  end

  test "complete flow with resume replacement" do
    new_resume = fixture_file_upload('new_resume.pdf', 'application/pdf')

    # Create initial form
    post emails_path, params: {
      emails: "hr@company.com",
      subject: "Test",
      body: "Test",
      resume: @resume_file
    }

    # Edit with new resume
    get edit_emails_path
    post emails_path, params: {
      emails: "hr@company.com",
      subject: "Test",
      body: "Test",
      resume: new_resume
    }

    # Verify new resume is stored
    token = session[:email_data_key]
    new_data = Rails.cache.read("email_form_#{token}")
    assert_equal "new_resume.pdf", new_data["resume_filename"]
  end

  test "view email logs after sending" do
    post emails_path, params: {
      emails: "hr1@company.com, hr2@company.com",
      subject: "Test",
      body: "Test",
      resume: @resume_file
    }

    post send_emails_emails_path

    get email_logs_path
    assert_response :success
  end

  test "show validation errors on form submission" do
    post emails_path, params: {
      emails: "",
      subject: "Test",
      body: "Test",
      resume: @resume_file
    }

    assert_response :unprocessable_entity
  end

  test "show file type validation error" do
    txt_file = fixture_file_upload('invalid.txt', 'text/plain')
    post emails_path, params: {
      emails: "hr@company.com",
      subject: "Test",
      body: "Test",
      resume: txt_file
    }

    assert_response :unprocessable_entity
  end

  test "handle multiple independent form submissions" do
    # First submission
    post emails_path, params: {
      emails: "hr1@company.com",
      subject: "First",
      body: "First",
      resume: @resume_file
    }
    first_token = session[:email_data_key]

    # Second submission
    post emails_path, params: {
      emails: "hr2@company.com",
      subject: "Second",
      body: "Second",
      resume: @resume_file
    }
    second_token = session[:email_data_key]

    # Tokens should be different
    assert_not_equal first_token, second_token

    # Both should have valid data
    first_data = Rails.cache.read("email_form_#{first_token}")
    second_data = Rails.cache.read("email_form_#{second_token}")
    assert_equal ["hr1@company.com"], first_data["emails"]
    assert_equal ["hr2@company.com"], second_data["emails"]
  end

  test "jobs execute and send actual emails" do
    # Submit form
    post emails_path, params: {
      emails: "hr@company.com",
      subject: "Test Job",
      body: "<p>Application</p>",
      resume: @resume_file
    }

    # Send
    post send_emails_emails_path

    # Perform jobs
    assert_enqueued_jobs(1, only: SendResumeJob)
    perform_enqueued_jobs

    # Verify email was sent
    assert_emails 1
  end

  test "accessing confirm without session redirects to new" do
    reset_session
    get confirm_emails_path
    assert_redirected_to new_email_path
  end

  test "accessing edit without session redirects to new" do
    reset_session
    get edit_emails_path
    assert_redirected_to new_email_path
  end

  test "accessing send without session redirects to new" do
    reset_session
    post send_emails_emails_path
    assert_redirected_to new_email_path
  end

  test "handle emails with extra whitespace" do
    post emails_path, params: {
      emails: "  hr1@company.com  ,  hr2@company.com  ",
      subject: "Test",
      body: "Test",
      resume: @resume_file
    }

    token = session[:email_data_key]
    cached_data = Rails.cache.read("email_form_#{token}")
    assert_equal 2, cached_data["emails"].length
  end

  test "deduplicate email addresses" do
    post emails_path, params: {
      emails: "hr@company.com, hr@company.com, hr@company.com",
      subject: "Test",
      body: "Test",
      resume: @resume_file
    }

    token = session[:email_data_key]
    cached_data = Rails.cache.read("email_form_#{token}")
    assert_equal 1, cached_data["emails"].length
  end

  test "handle large email body" do
    large_body = "<p>" + ("A" * 5000) + "</p>"
    post emails_path, params: {
      emails: "hr@company.com",
      subject: "Test",
      body: large_body,
      resume: @resume_file
    }

    assert_redirected_to confirm_emails_path
  end
end
