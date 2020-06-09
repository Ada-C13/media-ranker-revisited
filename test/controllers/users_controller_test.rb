require "test_helper"

describe UsersController do
  describe 'auth_callback' do
    it 'logs in an existing user and redirects to the root route' do
      start_count = User.count
      user = users(:dan)

      perform_login(user)
      must_redirect_to root_path
      session[:user_id].must_equal user.id

      User.count.must_equal start_count
    end

    it 'creates an account for a new user and redirects to the root route' do
      start_count = User.count
      user = User.new(provider: "github", uid: 99999, name: "test_user", email: "test@user.com")

      perform_login(user)
      must_redirect_to root_path
      session[:user_id].must_equal User.last.id

      User.count.must_equal start_count + 1
    end

    it 'redirects to root path if given invalid user data' do
      start_count = User.count
      user = User.new(provider: 'test', uid: -1)

      perform_login(user)
      must_redirect_to root_path
      session[:user_id].must_equal nil

      User.count.must_equal start_count
    end
  end
end
