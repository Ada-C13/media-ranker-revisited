require "test_helper"

describe UsersController do
  describe "auth_callback" do
    it "logs in an existing user" do
      start_count = User.count
      user = users(:grace)
    
      perform_login(user)
      must_redirect_to root_path
      session[:user_id].must_equal  user.id
    
      User.count.must_equal start_count
    end

    it "creates a new user" do
      start_count = User.count
      user = User.new(provider: "github", uid: 99999, name: "test_user", email: "test@user.com")
    
      perform_login(user)

      must_redirect_to root_path
    
      User.count.must_equal start_count + 1
    
      session[:user_id].must_equal User.last.id
    end

    it "redirects to the root route if given invalid user data" do
      start_count = User.count
      user = User.new(provider: "github", name: "test_user", email: "test@user.com")
    
      perform_login(user)

      must_redirect_to root_path
    
      User.count.must_equal start_count
    
      session[:user_id].must_equal nil
    end
    
  end
end
