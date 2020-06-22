require "test_helper"

describe UsersController do
  describe "auth_callback" do
    it "logs in an existing user and redirects to the root route" do
      start_count = User.count

      user = users(:grace)

      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(user))

      get auth_callback_path(:github)

      must_redirect_to root_path

      session[:user_id].must_equal user.id

      User.count.must_equal start_count
    end
  end

  describe "login" do
    it "can login an existing user" do
      user = perform_login(users(:ada))
      must_respond_with :redirect
    end

    it "can login a new user" do
      new_user = User.new(uid: 11111, username: "Rose", provider: 'github', email: 'rose@rose.rose')
      expect {
        login_user = perform_login(new_user)
    }.must_change "User.count", 1

      must_respond_with :redirect
    end
  end

  describe "logout" do
    it "can logout an existing user" do
      perform_login

      expect(session[:user_id]).wont_be_nil

      delete logout_path

      expect(session[:user_id]).must_be_nil

      must_respond_with :redirect
      must_redirect_to root_path
    end
  end
end
