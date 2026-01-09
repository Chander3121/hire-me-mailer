#!/bin/bash
# Job Mailer - Test Command Examples
# Copy and paste these commands in your terminal to run various test scenarios

echo "=== Job Mailer Test Commands ==="

# ===== RUN ALL TESTS =====
echo "
# Run complete test suite
rails test
"

# ===== RUN BY FILE =====
echo "
# Run controller tests
rails test test/controllers/emails_controller_test.rb

# Run job tests  
rails test test/jobs/send_resume_job_test.rb

# Run mailer tests
rails test test/mailers/hr_mailer_test.rb

# Run model tests
rails test test/models/email_log_test.rb

# Run integration tests
rails test test/integration/email_flow_test.rb
"

# ===== RUN SPECIFIC TEST CLASSES =====
echo "
# Run specific test class
rails test test/controllers/emails_controller_test.rb:EmailsControllerTest
rails test test/jobs/send_resume_job_test.rb:SendResumeJobTest
rails test test/integration/email_flow_test.rb:EmailFlowTest
"

# ===== RUN SPECIFIC TEST CASE =====
echo "
# Run single test case
rails test test/controllers/emails_controller_test.rb -n test_should_accept_valid_form_submission_with_single_email
rails test test/jobs/send_resume_job_test.rb -n test_should_send_email_to_correct_recipient
rails test test/mailers/hr_mailer_test.rb -n test_should_preserve_HTML_formatting_in_body
rails test test/models/email_log_test.rb -n test_should_require_recipient
rails test test/integration/email_flow_test.rb -n test_complete_flow
"

# ===== RUN WITH OPTIONS =====
echo "
# Run with verbose output
rails test -v

# Run with failure details
rails test test/controllers/emails_controller_test.rb --verbose

# Run with short format
rails test --format short

# Run tests in specific order
rails test --order sorted
"

# ===== RUN SPECIFIC FEATURE TESTS =====
echo "
# Test file upload validation
rails test test/controllers/emails_controller_test.rb -n /file/

# Test email validation
rails test test/controllers/emails_controller_test.rb -n /email/

# Test job processing
rails test test/jobs/send_resume_job_test.rb

# Test complete workflows
rails test test/integration/email_flow_test.rb -n /complete/

# Test edit functionality
rails test test/controllers/emails_controller_test.rb -n /edit/
"

# ===== RUN QUICK SMOKE TESTS =====
echo "
# Run only model tests (fastest)
rails test test/models/

# Run only controller tests
rails test test/controllers/

# Run job tests
rails test test/jobs/

# Skip integration tests for quick feedback
rails test test/controllers/ test/models/ test/jobs/ test/mailers/
"

# ===== ADVANCED OPTIONS =====
echo "
# Run with parallel workers (faster)
rails test --workers=4

# Run tests matching pattern
rails test --grep form

# Run tests NOT matching pattern
rails test --grep /\\bnot\\b/

# Run with seed for reproducibility
rails test --seed 12345

# List all tests without running
rails test --list

# Generate test report
rails test 2>&1 | tee test_report.txt
"

# ===== WITH COVERAGE =====
echo "
# Run tests with coverage report
bundle exec rails test  # Requires simplecov gem

# Check coverage for specific file
bundle exec rails test test/controllers/emails_controller_test.rb --coverage
"

# ===== DEBUGGING OPTIONS =====
echo "
# Run with debugging enabled
RUBYOPT=-W0 rails test test/controllers/emails_controller_test.rb

# Run with backtrace on failure
rails test -b

# Run single test with pry breakpoint
# Add 'binding.pry' in test, then:
rails test test/controllers/emails_controller_test.rb -n test_name

# Show timing info
rails test -v 2>&1 | grep -E 'Finished|assertions'
"

# ===== CI/CD COMMANDS =====
echo "
# Setup test database
rails db:test:prepare

# Run full test suite for CI
RAILS_ENV=test bundle install --without development
rails db:test:prepare
rails test

# Generate test report for CI
rails test --format json > test_results.json
"

# ===== WATCH MODE (requires guard) =====
echo "
# Run tests in watch mode (auto-rerun on file changes)
bundle exec guard init
bundle exec guard

# Or use this command directly:
watch -n 2 'rails test'
"

# ===== TEST SPECIFIC FLOWS =====
echo "
# Test complete form-to-send workflow
rails test test/integration/email_flow_test.rb -n test_complete_flow

# Test form submission with validation
rails test test/controllers/emails_controller_test.rb -n test_should_accept_valid_form_submission_with_single_email

# Test file upload validation
rails test test/controllers/emails_controller_test.rb -n test_should_reject_invalid_file_type

# Test edit workflow
rails test test/controllers/emails_controller_test.rb -n test_should_preserve_resume_if_not_re_uploaded_during_edit

# Test job execution
rails test test/jobs/send_resume_job_test.rb -n test_should_perform_job_and_send_email

# Test security
rails test test/controllers/emails_controller_test.rb -n test_should_redirect_to_new_if_no_session_data
"

# ===== USEFUL ALIASES =====
echo "
# Add these to ~/.zshrc or ~/.bash_profile for quick testing:

# Test all
alias test_all='rails test'

# Test controllers
alias test_c='rails test test/controllers/'

# Test models
alias test_m='rails test test/models/'

# Test jobs
alias test_j='rails test test/jobs/'

# Test integration
alias test_i='rails test test/integration/'

# Test verbose
alias test_v='rails test -v'

# Quick test (without integration)
alias test_quick='rails test test/controllers/ test/models/ test/jobs/ test/mailers/'
"

echo "
=== Examples of Common Test Commands ===

1. Run everything:
   rails test

2. Run just controllers:
   rails test test/controllers/emails_controller_test.rb

3. Run one test:
   rails test test/models/email_log_test.rb -n test_should_require_recipient

4. Run tests matching pattern:
   rails test --grep file_upload

5. Run with verbose output:
   rails test -v

6. Run jobs and watch for output:
   watch 'rails test test/jobs/send_resume_job_test.rb'

7. Run integration workflow tests:
   rails test test/integration/email_flow_test.rb

8. Quick feedback (skip slow integration tests):
   rails test test/controllers/ test/models/ test/jobs/ test/mailers/
"
