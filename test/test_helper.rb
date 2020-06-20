ENV["RAILS_ENV"] = "test"
require File.expand_path("../../config/environment", __FILE__)
require "rails/test_help"
require "minitest/rails"
require "minitest/skip_dsl"
require "minitest/reporters"  # for Colorized output

#  For colorful output!
Minitest::Reporters.use!(
  Minitest::Reporters::SpecReporter.new,
  ENV,
  Minitest.backtrace_filter
)

# To add Capybara feature tests add `gem "minitest-rails-capybara"`
# to the test group in the Gemfile and uncomment the following:
# require "minitest/rails/capybara"

# Uncomment for awesome colorful output
# require "minitest/pride"

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all
  # Add more helper methods to be used by all tests here...
  # To be able to mock the interaction with Github
  # We are in test mode
  def setup
    # Once you have enabled test mode, all requests
    # to OmniAuth will be short circuited to use the mock authentication hash.
    # A request to /auth/provider will redirect immediately to /auth/provider/callback.
    OmniAuth.config.test_mode = true
  end

  # Test helper method to generate a mock auth hash
  # for fixture data
  # Only into our test, dont mocking in real life
  def mock_auth_hash(user)
    return {
      provider: user.provider,
      uid: user.uid,
      username: user.username,
      info: {
        email: user.email,
        name: user.username,
      },
    }
  end

  def perform_login(user = nil)
    user ||= User.first

    OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(user))

    # Act try to callcck route
    get omniauth_calback_path(:github)
    # Need to find that user, new user: id is nil. Needs go back and find the user.

    user = User.find_by(uid: user.uid, username: user.username)
    expect(user).wont_be_nil

    # Verify the User ID was saved - If that didn't wwork, this test in invalid
    expect(session[:user_id]).must_equal user.id
    return user
  end
end
