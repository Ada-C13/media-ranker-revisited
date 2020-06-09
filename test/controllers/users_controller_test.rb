require "test_helper"

describe UsersController do

  describe "auth_callback" do
    it "logs in an existing user and redirects to the root route" do
      start_count = User.count
      user = users(:dan)

      perform_login(user)
      
      must_redirect_to root_path
      _(session[:user_id]).must_equal user.id
      _(User.count).must_equal start_count
    end

    it "creates an account for a new user and redirects to the root route" do
      start_count = User.count
      user = User.new(provider: "github", uid: 99999, username: "test_user", email: "test@user.com")
    
      perform_login(user)

      must_redirect_to root_path
      _(User.count).must_equal start_count + 1
      _(session[:user_id]).must_equal User.last.id
    end

    it "redirects to the login route if given invalid user data" do
    end
  end

end
