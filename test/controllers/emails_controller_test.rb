require "test_helper"

class EmailsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @resume_file = fixture_file_upload("resume.pdf", "application/pdf")
  end

  # ===== NEW PAGE TESTS =====
  test "should display form page successfully" do
    get new_email_path
    assert_response :success
    assert_select "form"
  end

  # ===== CREATE TESTS =====
  test "should accept valid form submission with single email" do
    post emails_path, params: {
      emails: "hr@company.com",
      subject: "Job Application",
      body: "I am interested in the position",
      resume: @resume_file
    }

    assert_redirected_to confirm_emails_path
    assert_not_nil session[:email_data_key]
  end

  test "should accept multiple emails separated by comma" do
    post emails_path, params: {
      emails: "hr1@company.com, hr2@company.com, hr3@company.com",
      subject: "Job Application",
      body: "I am interested",
      resume: @resume_file
    }

    assert_redirected_to confirm_emails_path
    follow_redirect!
    token = session[:email_data_key]
    assert_not_nil token
    cached_data = Rails.cache.read("email_form_#{token}")
    assert_not_nil cached_data
    assert_equal 3, cached_data["emails"].length
  end

  test "should reject submission without emails" do
    post emails_path, params: {
      emails: "",
      subject: "Job Application",
      body: "I am interested",
      resume: @resume_file
    }

    assert_response :unprocessable_entity
  end

  test "should reject submission without subject" do
    post emails_path, params: {
      emails: "hr@company.com",
      subject: "",
      body: "I am interested",
      resume: @resume_file
    }

    assert_response :unprocessable_entity
  end

  test "should reject submission without body" do
    post emails_path, params: {
      emails: "hr@company.com",
      subject: "Job Application",
      body: "",
      resume: @resume_file
    }

    assert_response :unprocessable_entity
  end

  test "should reject submission without resume" do
    post emails_path, params: {
      emails: "hr@company.com",
      subject: "Job Application",
      body: "I am interested"
    }

    assert_response :unprocessable_entity
  end

  test "should reject invalid file type txt" do
    txt_file = fixture_file_upload("invalid.txt", "text/plain")
    post emails_path, params: {
      emails: "hr@company.com",
      subject: "Job Application",
      body: "I am interested",
      resume: txt_file
    }

    assert_response :unprocessable_entity
  end

  test "should accept PDF resume" do
    pdf_file = fixture_file_upload("resume.pdf", "application/pdf")
    post emails_path, params: {
      emails: "hr@company.com",
      subject: "Job Application",
      body: "I am interested",
      resume: pdf_file
    }

    assert_redirected_to confirm_emails_path
  end

  test "should accept DOCX resume" do
    docx_file = fixture_file_upload("resume.docx", "application/vnd.openxmlformats-officedocument.wordprocessingml.document")
    post emails_path, params: {
      emails: "hr@company.com",
      subject: "Job Application",
      body: "I am interested",
      resume: docx_file
    }

    assert_redirected_to confirm_emails_path
  end

  test "should store form data in cache with token" do
    post emails_path, params: {
      emails: "hr@company.com",
      subject: "Test Subject",
      body: "<p>Test Body</p>",
      resume: @resume_file
    }

    token = session[:email_data_key]
    assert_not_nil token

    cached_data = Rails.cache.read("email_form_#{token}")
    assert_not_nil cached_data
    assert_equal [ "hr@company.com" ], cached_data["emails"]
    assert_equal "Test Subject", cached_data["subject"]
  end

  # ===== CONFIRM TESTS =====
  test "should display confirmation page" do
    post emails_path, params: {
      emails: "hr@company.com",
      subject: "Test",
      body: "Test",
      resume: @resume_file
    }

    get confirm_emails_path
    assert_response :success
  end

  test "should redirect to new if no session for confirm" do
    reset_session
    get confirm_emails_path
    assert_redirected_to new_email_path
  end

  # ===== EDIT TESTS =====
  test "should display edit form with pre-filled data" do
    post emails_path, params: {
      emails: "hr@company.com",
      subject: "Original",
      body: "Original",
      resume: @resume_file
    }

    get edit_emails_path
    assert_response :success
  end

  test "should preserve resume if not re-uploaded" do
    post emails_path, params: {
      emails: "hr@company.com",
      subject: "Original",
      body: "Original",
      resume: @resume_file
    }

    post emails_path, params: {
      emails: "hr@company.com",
      subject: "Updated",
      body: "Updated"
    }

    token = session[:email_data_key]
    cached_data = Rails.cache.read("email_form_#{token}")
    assert_not_nil cached_data["resume_path"]
  end

  test "should replace resume when new file uploaded" do
    post emails_path, params: {
      emails: "hr@company.com",
      subject: "Original",
      body: "Original",
      resume: @resume_file
    }

    new_file = fixture_file_upload("new_resume.pdf", "application/pdf")
    post emails_path, params: {
      emails: "hr@company.com",
      subject: "Updated",
      body: "Updated",
      resume: new_file
    }

    assert_redirected_to confirm_emails_path
  end

  # ===== SEND TESTS =====
  test "should create email logs for each recipient" do
    post emails_path, params: {
      emails: "hr1@company.com, hr2@company.com",
      subject: "Test",
      body: "Test",
      resume: @resume_file
    }

    assert_difference("EmailLog.count", 2) do
      post send_emails_emails_path
    end
  end

  test "should enqueue jobs for each recipient" do
    post emails_path, params: {
      emails: "hr1@company.com, hr2@company.com",
      subject: "Test",
      body: "Test",
      resume: @resume_file
    }

    assert_enqueued_jobs(2, only: SendResumeJob) do
      post send_emails_emails_path
    end
  end

  test "should set email logs to pending" do
    EmailLog.delete_all  # Clear any existing logs
    post emails_path, params: {
      emails: "hr@company.com",
      subject: "Test",
      body: "Test",
      resume: @resume_file
    }

    post send_emails_emails_path

    assert_equal 1, EmailLog.count
    assert_equal "pending", EmailLog.first.status
  end

  test "should redirect to email logs after sending" do
    post emails_path, params: {
      emails: "hr@company.com",
      subject: "Test",
      body: "Test",
      resume: @resume_file
    }

    post send_emails_emails_path
    assert_redirected_to email_logs_path
  end

  test "should clear session after sending" do
    post emails_path, params: {
      emails: "hr@company.com",
      subject: "Test",
      body: "Test",
      resume: @resume_file
    }

    token = session[:email_data_key]
    post send_emails_emails_path

    assert_nil session[:email_data_key]
  end

  # ===== EDGE CASES =====
  test "should handle emails with whitespace" do
    post emails_path, params: {
      emails: "  hr1@company.com  ,  hr2@company.com  ",
      subject: "Test",
      body: "Test",
      resume: @resume_file
    }

    assert_redirected_to confirm_emails_path
  end

  test "should reject duplicate emails" do
    post emails_path, params: {
      emails: "hr@company.com, hr@company.com",
      subject: "Test",
      body: "Test",
      resume: @resume_file
    }

    token = session[:email_data_key]
    cached_data = Rails.cache.read("email_form_#{token}")
    assert_equal 1, cached_data["emails"].length
  end

  test "should handle long email body" do
    long_body = "A" * 5000
    post emails_path, params: {
      emails: "hr@company.com",
      subject: "Test",
      body: long_body,
      resume: @resume_file
    }

    assert_redirected_to confirm_emails_path
  end
end
