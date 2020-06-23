require "test_helper"

describe UsersController do
  describe "login" do
    it "logs in an existing user and redirects to the root route" do
      start_count = User.count

      user = perform_login(users(:ada))

      must_redirect_to root_path

      # Should not have created a new user
      User.count.must_equal start_count
    end 

    it "creates an account for a new user and redirects to the root route" do
      start_count = User.count

      new_user = User.new(provider: "github", uid: 99999, name: "test_user", email: "test@user.com")

      logged_in_user = perform_login(new_user)

      must_redirect_to root_path

      # Should have created a new user
      User.count.must_equal start_count + 1
    end

    it "redirects to the login route if given invalid user data" do
      new_user = User.new(uid: nil, username: nil, email: "test@user.com", provider: "github")
      perform_login(new_user)
      must_redirect_to root_path
    end
  end 

  describe "logout" do 
    it "can logout an existing user" do
      perform_login(users(:ada))

      expect(session[:user_id]).wont_be_nil

      delete logout_path, params: {}

      expect(session[:user_id]).must_be_nil
      must_redirect_to root_path
    end
  end 
end
