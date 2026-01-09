# Job Mailer - Comprehensive Test Guide

This document describes the complete test suite for the Job Mailer application, covering all functionality from form submission to email delivery.

## Test Coverage Overview

The test suite includes **100+ test cases** organized into 5 main categories:

### 1. **Controller Tests** (`test/controllers/emails_controller_test.rb`)
- **NEW page**: Form page display and elements
- **CREATE (form submission)**: Validation, file handling, caching
- **CONFIRM page**: Preview display and data retrieval
- **EDIT page**: Form pre-filling and data preservation
- **SEND_EMAILS**: Job queueing and cleanup
- **Edge cases**: Whitespace handling, duplicates, large data

#### Key Scenarios Tested:
✅ Display form page with all fields
✅ Accept single and multiple email addresses (comma/newline separated)
✅ Reject empty or invalid emails
✅ Accept only PDF/DOC/DOCX files
✅ Reject files larger than 10MB
✅ Cache form data with secure token
✅ Handle multiple form submissions with different tokens
✅ Preserve resume file when editing without re-uploading
✅ Replace resume when new file uploaded during edit
✅ Redirect properly after each step

### 2. **Job Tests** (`test/jobs/send_resume_job_test.rb`)
- **Job enqueuing**: Proper parameters and delays
- **Job execution**: Email delivery and status updates
- **Error handling**: Invalid paths, missing files
- **Batch processing**: Multiple jobs in queue

#### Key Scenarios Tested:
✅ Enqueue jobs with correct arguments
✅ Send email to correct recipient
✅ Include subject and body in sent email
✅ Attach resume file
✅ Update EmailLog status to 'sent'
✅ Set sent_at timestamp
✅ Handle job failures gracefully
✅ Process multiple jobs in queue with staggered delays

### 3. **Mailer Tests** (`test/mailers/hr_mailer_test.rb`)
- **Email composition**: Subject, body, recipient
- **Attachments**: Resume file inclusion
- **HTML formatting**: Preserving rich text

#### Key Scenarios Tested:
✅ Send email to correct recipient
✅ Include correct subject line
✅ Preserve HTML formatting in body
✅ Attach resume file with content
✅ Set from address
✅ Handle special characters and HTML tags
✅ Send to multiple different recipients

### 4. **Model Tests** (`test/models/email_log_test.rb`)
- **Validation**: Required fields, email format
- **Status management**: pending/sent/failed states
- **Data persistence**: Storage and retrieval
- **Timestamps**: Creation and sent tracking

#### Key Scenarios Tested:
✅ Require recipient, subject, status fields
✅ Validate email format (accept valid, reject invalid)
✅ Default status to 'pending'
✅ Track sent_at timestamp
✅ Allow status transitions
✅ Preserve data integrity
✅ Support querying by recipient or status
✅ Allow updates and deletions

### 5. **Integration Tests** (`test/integration/email_flow_test.rb`)
- **Complete workflows**: NEW → CONFIRM → SEND
- **Edit workflows**: NEW → CONFIRM → EDIT → CONFIRM → SEND
- **Resume replacement**: Editing with new file upload
- **Validation errors**: Form rejections
- **Email logs**: Viewing sent emails
- **Security**: Session protection
- **Browser behavior**: Back button, multiple tabs

#### Key Scenarios Tested:
✅ Complete flow from form to email delivery
✅ Edit form and maintain or replace resume
✅ Show validation errors on page
✅ Reject invalid file types
✅ Handle multiple independent submissions
✅ Execute jobs and deliver emails
✅ Protect confirm/edit/send without session
✅ Normalize emails (whitespace, duplicates)
✅ Handle large form data
✅ Preserve state across browser navigation

## Running the Tests

### Run All Tests
```bash
rails test
```

### Run Specific Test File
```bash
# Controller tests
rails test test/controllers/emails_controller_test.rb

# Job tests
rails test test/jobs/send_resume_job_test.rb

# Mailer tests
rails test test/mailers/hr_mailer_test.rb

# Model tests
rails test test/models/email_log_test.rb

# Integration tests
rails test test/integration/email_flow_test.rb
```

### Run Specific Test Class
```bash
rails test test/controllers/emails_controller_test.rb:EmailsControllerTest
```

### Run Specific Test Case
```bash
rails test test/controllers/emails_controller_test.rb -n "test_should_accept_valid_form_submission_with_single_email"
```

### Run with Verbose Output
```bash
rails test -v
```

### Run with Coverage Report
```bash
bundle exec simplecov
rails test
```

## Test Fixtures

Test fixtures are located in `test/fixtures/files/`:

- **resume.pdf** - Valid PDF resume (used in most tests)
- **resume.docx** - Valid DOCX resume
- **resume.doc** - Valid DOC resume
- **invalid.txt** - Invalid text file (for negative tests)
- **new_resume.pdf** - Alternative PDF (for edit/replace tests)
- **large_resume.pdf** - Large PDF (for size limit tests)

All fixtures are minimal valid documents suitable for testing.

## Test Data Setup

Each test file includes a `setup` block that:

1. **Creates test fixtures** - Sample resume files
2. **Clears email deliveries** - Ensures clean state
3. **Initializes test data** - Valid attributes for models

Example setup:
```ruby
setup do
  @resume_file = fixture_file_upload('resume.pdf', 'application/pdf')
  ActionMailer::Base.deliveries.clear
end
```

## Understanding Test Results

### Success Output
```
Finished in 0.123456s
120 tests, 450 assertions, 0 failures, 0 errors
```

### Failure Example
```
FAIL: test_should_accept_single_email
Expected redirect to /emails/confirm, got 422
```

### Common Assertions Used

- `assert_response :success` - Check HTTP 200
- `assert_redirected_to path` - Check redirect location
- `assert_difference { Model.count }` - Check record creation
- `assert_emails 1` - Check email was sent
- `assert_enqueued_jobs(2)` - Check jobs queued
- `assert_select 'selector'` - Check HTML element
- `assert_equal expected, actual` - Check equality
- `assert_not_nil value` - Check not null

## Test Scenarios by Feature

### File Upload & Validation
Tests for:
- File type restrictions (PDF/DOC/DOCX only)
- File size limits (max 10MB)
- Client-side and server-side validation
- File storage in tmp directory
- Filename tracking

**Test Files:**
- Controller: "should reject invalid file type (txt)"
- Controller: "should accept PDF/DOC/DOCX resume"
- Controller: "should reject file larger than 10MB"
- Job: "should handle resume_path that doesn't exist"

### Form Data Persistence
Tests for:
- Cache-based session storage
- Secure token generation
- 30-minute cache expiry
- Session cleanup after send
- Data retrieval on confirm/edit

**Test Files:**
- Controller: "should store form data in cache with token"
- Controller: "should clean up session on form resubmission"
- Integration: "complete flow: create form, confirm, and send emails"

### Email Composition & Sending
Tests for:
- Multiple recipient handling
- Subject and body inclusion
- HTML formatting preservation
- Resume attachment
- Status tracking

**Test Files:**
- Mailer: "should send resume email with correct recipient"
- Mailer: "should preserve HTML formatting in body"
- Job: "should send email to correct recipient"
- Job: "should update email log status to sent after job completion"

### Form Editing
Tests for:
- Pre-filling existing data
- Preserving resume when not re-uploading
- Replacing resume when new file selected
- Maintaining session across edits
- Multiple edit cycles

**Test Files:**
- Controller: "should display edit form with pre-filled data"
- Controller: "should preserve resume if not re-uploaded during edit"
- Controller: "should replace resume when new file uploaded during edit"
- Integration: "complete flow with edit functionality"

### Email Logs
Tests for:
- Creating log entries
- Status transitions (pending → sent)
- Recipient and subject tracking
- Timestamp management
- Log querying and filtering

**Test Files:**
- Model: "should create valid email log"
- Model: "should allow changing status to sent"
- Model: "should be retrievable by status"
- Job: "should set sent_at timestamp when email is sent"

## Edge Cases & Security

### Email Handling
- Whitespace normalization
- Duplicate removal
- Invalid format rejection
- Special characters

**Tests:**
- "should handle emails with extra whitespace"
- "should reject duplicate emails"
- "should accept valid email addresses"
- "should reject invalid email addresses"

### Data Security
- Session token validation
- Cache expiry enforcement
- File access control
- CSRF protection

**Tests:**
- "accessing confirm without session redirects to new"
- "accessing edit without session redirects to new"
- "session should be cleared after sending"

### Large Data
- Long email bodies (10,000+ characters)
- Many recipients (100+)
- Large files (near 10MB limit)

**Tests:**
- "should handle large email body"
- "should handle very long email body"
- "should handle file larger than 10MB"

## Continuous Integration

The test suite is designed to run in CI/CD pipelines:

### Run with CI Configuration
```bash
RAILS_ENV=test bundle exec rake ci
```

Or manually:
```bash
bundle install
rails db:test:prepare
rails test
```

### GitHub Actions Example
```yaml
- name: Run tests
  run: rails test
```

## Performance Testing

Recommended test execution times:
- **Controller tests**: < 1 second
- **Job tests**: < 2 seconds (includes job processing)
- **Mailer tests**: < 1 second
- **Model tests**: < 1 second
- **Integration tests**: < 5 seconds

**Total suite**: < 10 seconds

If tests take longer:
1. Check for slow database queries
2. Verify test fixtures are small
3. Use `parallelize(workers: :number_of_processors)` for parallel execution

## Adding New Tests

When adding new features, follow this pattern:

```ruby
describe "Feature Name" do
  setup do
    # Setup test data
    @test_data = TestModel.create!(attributes)
  end

  test "should do something" do
    # Arrange
    setup_preconditions

    # Act
    perform_action

    # Assert
    verify_results
  end
end
```

### Example: Testing new email validation
```ruby
test "should validate custom rule" do
  post emails_path, params: {
    emails: "invalid-email-format",
    subject: "Test",
    body: "Test",
    resume: @resume_file
  }

  assert_response :unprocessable_entity
  assert_select 'p', /email must match pattern/i
end
```

## Debugging Failed Tests

### View Detailed Output
```bash
rails test test/path/to/test.rb -v
```

### Use Binding for Breakpoints
```ruby
test "should do something" do
  binding.pry  # Execution pauses here
  post emails_path, params: {...}
end
```

### Save HTML Response
```ruby
test "should display form" do
  get emails_new_path
  puts response.body  # Print HTML to console
end
```

### Check Database State
```ruby
test "should create record" do
  assert_difference 'Model.count' do
    Model.create!(params)
  end
  binding.pry  # Inspect Model.last
end
```

## Maintenance

### Update Tests When:
- API endpoints change
- Validation rules change
- Email format changes
- File restrictions change
- Cache expiry changes

### Regular Review:
- Check for flaky tests (inconsistent failures)
- Update fixtures if format requirements change
- Add tests for reported bugs before fixing
- Refactor test code to remove duplication

## Summary

The test suite provides comprehensive coverage of:
- ✅ Form submission and validation
- ✅ File upload and processing
- ✅ Data caching and session management
- ✅ Email composition and delivery
- ✅ Background job processing
- ✅ Database model operations
- ✅ User workflows and edge cases
- ✅ Security and error handling

With 100+ tests across 5 test files, the suite ensures reliability and maintainability as the application evolves.
