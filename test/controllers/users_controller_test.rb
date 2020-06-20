require "test_helper"

describe UsersController do
  describe "login" do
    it "can log in an existing user" do
      user = perform_login(users(:haben))
      must_respond_with :redirect
    end

    it "can login in a new user" do
      new_user = User.new(uid: "2244", username: "havana", provider: "github", email: "havana@gmail.com")

      expect do
        logged_in_user = perform_login(new_user)
      end.must_change "User.count", 1

      must_respond_with :redirect
    end
  end

  describe "logout" do
    it "can logout as existing user" do
      perform_login

      expect(session[:user_id]).wont_be_nil

      delete logout_path, params: {}

      expect(session[:user_id]).must_be_nil
      must_redirect_to root_path
    end
  end

  describe "going to the detail page of the current user" do
    it "responds with success if a user is logged in" do
      perform_login

      get current_user_path

      must_respond_with :success
    end

    it "responds with a redirect if no user is logged in" do
      get current_user_path
      must_respond_with :redirect
    end
  end
end
