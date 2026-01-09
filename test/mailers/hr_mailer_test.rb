require "test_helper"

class HrMailerTest < ActionMailer::TestCase
  setup do
    @resume_path = fixture_file_upload('resume.pdf', 'application/pdf').path
  end

  test "should send resume email with correct recipient" do
    assert_emails 1 do
      HrMailer.send_resume(
        recipient: "hr@company.com",
        subject: "Test Application",
        body: "<p>Application for Senior Developer</p>",
        resume_path: @resume_path
      ).deliver_now
    end
  end

  test "should have correct subject line" do
    email = HrMailer.send_resume(
      recipient: "hr@company.com",
      subject: "Senior Rails Developer Application",
      body: "<p>Please consider my application</p>",
      resume_path: @resume_path
    )
    
    assert_equal "Senior Rails Developer Application", email.subject
  end

  test "should include email body in message" do
    body_text = "<p>I am very interested in this position</p>"
    email = HrMailer.send_resume(
      recipient: "hr@company.com",
      subject: "Test",
      body: body_text,
      resume_path: @resume_path
    )
    
    assert_includes email.body.encoded, "I am very interested in this position"
  end

  test "should attach resume file" do
    email = HrMailer.send_resume(
      recipient: "hr@company.com",
      subject: "Test",
      body: "<p>Application</p>",
      resume_path: @resume_path
    )
    
    assert email.attachments.any? { |att| att.filename.include?('resume') }
  end

  test "should set from address" do
    email = HrMailer.send_resume(
      recipient: "hr@company.com",
      subject: "Test",
      body: "<p>Application</p>",
      resume_path: @resume_path
    )
    
    assert_not_nil email.from
  end

  test "should handle multiple special characters in body" do
    special_body = "<p>Testing &lt;test&gt; &amp; special chars</p>"
    assert_emails 1 do
      HrMailer.send_resume(
        recipient: "hr@company.com",
        subject: "Test",
        body: special_body,
        resume_path: @resume_path
      ).deliver_now
    end
  end

  test "should preserve HTML formatting in body" do
    html_body = "<h1>Application</h1><p>I am interested</p><ul><li>Skill 1</li></ul>"
    email = HrMailer.send_resume(
      recipient: "hr@company.com",
      subject: "Test",
      body: html_body,
      resume_path: @resume_path
    )
    
    # Check that HTML tags are preserved
    assert_includes email.body.encoded, "<h1>"
    assert_includes email.body.encoded, "<ul>"
  end

  test "should send to correct recipient email" do
    recipients = ["hr1@company.com", "hr2@company.com", "hr3@company.com"]
    
    recipients.each do |recipient|
      email = HrMailer.send_resume(
        recipient: recipient,
        subject: "Test",
        body: "<p>Application</p>",
        resume_path: @resume_path
      )
      
      assert_equal [recipient], email.to
    end
  end

  test "should include resume file content" do
    email = HrMailer.send_resume(
      recipient: "hr@company.com",
      subject: "Test",
      body: "<p>Application</p>",
      resume_path: @resume_path
    )
    
    attachment = email.attachments.first
    assert_not_nil attachment
    assert_not_empty attachment.body.to_s
  end
end
