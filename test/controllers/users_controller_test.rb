require "test_helper"

describe UsersController do

  describe 'login' do
    it 'can login an existing user' do
      user = perform_login(users(:kari))

      must_respond_with :redirect
    end

    it 'can login a new user' do
      new_user = User.new(username: 'leah', provider: 'github', uid: 123456789)

      expect {
        logged_in_user = perform_login(new_user)
      }.must_change "User.count", 1

      must_respond_with :redirect
    end
  end

  describe "logout" do
    it 'can log out an existing user' do
    perform_login
    expect(session[:user_id]).wont_be_nil

    post logout_path, params: {}
    expect(session[:user_id]).must_be_nil
    must_redirect_to root_path
    end

    it 'redirects to root path if a guest/non-logged in user tries to logout' do
      post logout_path, params: {}

      must_redirect_to root_path
    end
  end

end
