require "test_helper"

describe UsersController do
  describe "auth_callback" do
    # test/controllers/users_controller_test.rb
    it "logs in an existing user" do
      start_count = User.count
      user = users(:grace)

      perform_login(user)
      must_redirect_to root_path
      expect(session[:user_id]).must_equal user.id

      # Should *not* have created a new user
      expect(User.count).must_equal start_count
    end

    it "creates a new user" do
      start_count = User.count
      user = User.new(provider: "github", uid: 99999, username: "test_user", email: "test@user.com")
    
      perform_login(user)
      get auth_callback_path(:github)
    
      must_redirect_to root_path
    
      # Should have created a new user
      expect(User.count).must_equal start_count + 1
    
      # The new user's ID should be set in the session
      expect(session[:user_id]).must_equal User.last.id
    end
  end  

  describe "logout" do
    it "destroys session id and redirects to root_path" do
      perform_login

      delete logout_path

      expect(session[:merchant_id]).must_be_nil
      must_redirect_to root_path
    end
  end
end
