ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
    # Make fixture_file_upload available in all tests
    include ActionDispatch::TestProcess

    # Use the test adapter for Active Job so assert_enqueued_jobs works
    ActiveJob::Base.queue_adapter = :test

    # Simple helper to reset integration session between tests
    def reset_session
      if defined?(Capybara)
        Capybara.reset_sessions!
      else
        # For Rails integration tests, reinitialize the session object
        @integration_session = nil if defined?(@integration_session)
      end
    end
  end
end
ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end
