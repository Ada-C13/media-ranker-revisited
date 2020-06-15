require "test_helper"

describe UsersController do
  describe "auth_callback" do
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
    end
  end 
end
