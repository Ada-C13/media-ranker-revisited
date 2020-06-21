require "test_helper"

describe UsersController do

  describe 'auth_callback' do
    let(:user) { users(:dan) }

    it 'logs in an existing user and redirects to the root route' do
      start_count = User.count

      perform_login(user)
      must_redirect_to root_path
      session[:user_id].must_equal user.id

      User.count.must_equal start_count
    end

    it 'creates an account for a new user and redirects to the root route' do
      start_count = User.count
      params = mock_auth_hash(user)
      # new_user = User.new(params)

      perform_login(params)
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

    it 'can loggout a user and redirect to root path' do
      perform_login(user)
      expect(session[:user_id]).wont_be_nil
      delete logout_path
      expect(session[:user_id]).must_be_nil
      must_redirect_to root_path
    end

  end
end
