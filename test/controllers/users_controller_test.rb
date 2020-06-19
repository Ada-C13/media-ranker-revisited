require "test_helper"

describe UsersController do
  describe "auth_callback" do
    it "logs in an existing user and redirects to the root route" do
      start_count = User.count
      user = users(:dan)

      perform_login(user)

      must_redirect_to root_path

      session[:user_id].must_equal user.id

      User.count.must_equal start_count
    end

    it "creates an account for a new user and redirects to the root route" do
      new_user = User.new(
        provider: "github",
        uid: 9999,
        name: "freddie",
        email: "fred@mercury.com",
        username: "freddiemerc"
      )

      expect {
        perform_login(new_user)
      }.must_change "User.count", 1

      session[:user_id].must_equal User.last.id

    end

    it "redirects to the login route if given invalid user data" do
      start_count = User.count
      
      invalid_user = User.new(
        provider: "github",
        uid: 9999,
        name: "freddie",
        email: "fred@mercury.com"
      )

      expect {
        perform_login(invalid_user)
      }.wont_change "User.count"

      User.count.must_equal start_count

      must_respond_with :redirect
      must_redirect_to root_path

    end
    
  end

end
