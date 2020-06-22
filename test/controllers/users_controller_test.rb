require "test_helper"

describe UsersController do
  describe "logging in" do
    it "can login an existing user" do
      user = perform_login(users(:dan))

      assert_equal "Logged in as existing user #{user.username}.", flash[:result_text]
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

      assert_equal "Logged in as new user #{new_user.username}.", flash[:result_text]
      must_redirect_to root_path
    end
  end

  describe "logging out" do
    it "can log out an existing user" do
      perform_login
      expect(session[:user_id]).wont_be_nil

      post logout_path, params: {}
      assert_equal "Successfully logged out", flash[:result_text]
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
