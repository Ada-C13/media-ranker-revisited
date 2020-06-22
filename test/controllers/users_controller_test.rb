require "test_helper"

describe UsersController do
  describe "logging in" do
    it "can login an existing user" do
      user = perform_login(users(:dan))

      must_redirect_to root_path
    end

    it "can login a new user" do
      new_user = User.new(
        username: "Berti",
        provider: "github",
        email: "berti@email.com",
        uid: "743241"
      )

      expect {
        user = perform_login(new_user)
      }.must_change "User.count", 1

      must_redirect_to root_path
    end
  end

  describe "logging out" do
    it "can log out an existing user" do
      perform_login
      expect(session[:user_id]).wont_be_nil

      post logout_path, params: {}
      expect(session[:user_id]).must_be_nil
      must_redirect_to root_path
    end

    it "responds with an internal server error for a user who is not logged in" do
      expect(@login_user).must_be_nil

      post logout_path, params: {}

      expect(session[:user_id]).must_be_nil
      must_respond_with :internal_server_error
    end
  end
end
