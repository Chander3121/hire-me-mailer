require "test_helper"

class EmailLogTest < ActiveSupport::TestCase
  setup do
    @valid_attributes = {
      email: "hr@company.com",
      subject: "Job Application",
      status: 'pending'
    }
  end

  test "should create valid email log" do
    email_log = EmailLog.new(@valid_attributes)
    assert email_log.valid?
  end

  test "should require email" do
    email_log = EmailLog.new(@valid_attributes.except(:email))
    assert_not email_log.valid?
    assert email_log.errors[:email].any?
  end

  test "should require subject" do
    email_log = EmailLog.new(@valid_attributes.except(:subject))
    assert_not email_log.valid?
    assert email_log.errors[:subject].any?
  end

  test "should require status" do
    email_log = EmailLog.new(@valid_attributes.except(:status))
    assert_not email_log.valid?
    assert email_log.errors[:status].any?
  end

  test "should accept valid email addresses" do
    valid_emails = [
      "user@example.com",
      "firstname.lastname@example.com",
      "email@subdomain.example.com"
    ]

    valid_emails.each do |email|
      email_log = EmailLog.new(@valid_attributes.merge(email: email))
      assert email_log.valid?, "Should accept valid email #{email}"
    end
  end

  test "should reject invalid email addresses" do
    invalid_emails = [
      "notanemail",
      "missing@domain",
      "@nodomain.com",
      "spaces in@email.com"
    ]

    invalid_emails.each do |email|
      email_log = EmailLog.new(@valid_attributes.merge(email: email))
      assert_not email_log.valid?, "Should reject #{email}"
    end
  end

  test "should default status to pending" do
    email_log = EmailLog.create!(@valid_attributes)
    assert_equal 'pending', email_log.status
  end

  test "should set sent_at when status is sent" do
    email_log = EmailLog.create!(@valid_attributes)
    assert_nil email_log.sent_at

    email_log.update(status: 'sent', sent_at: Time.current)
    assert_not_nil email_log.sent_at
  end

  test "should track email creation timestamp" do
    email_log = EmailLog.create!(@valid_attributes)
    assert_not_nil email_log.created_at
  end

  test "should allow updating email" do
    email_log = EmailLog.create!(@valid_attributes)
    email_log.update(email: "newemail@example.com")
    assert_equal "newemail@example.com", email_log.email
  end

  test "should handle multiple email logs for same email" do
    email = "hr@company.com"

    log1 = EmailLog.create!(@valid_attributes.merge(email: email, subject: "Subject 1"))
    log2 = EmailLog.create!(@valid_attributes.merge(email: email, subject: "Subject 2"))

    logs = EmailLog.where(email: email)
    assert_equal 2, logs.count
  end

  test "should allow destroy" do
    email_log = EmailLog.create!(@valid_attributes)
    id = email_log.id

    email_log.destroy
    assert_nil EmailLog.find_by(id: id)
  end
end
