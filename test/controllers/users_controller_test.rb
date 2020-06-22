require "test_helper"

describe UsersController do
  describe "login" do 
    it "can log in as an existing user" do
      user = perform_login(users(:dan))
      expect{user}.wont_change "User.count"
      expect(flash[:result_text]).must_equal "Welcome back, #{user.username}!"
      must_respond_with :redirect
    end

    it "can log in as a new user" do
      new_user = User.new(uid:"11111", username: "Ross", provider: "github", avatar: "ppppppp", email: "ross@ada.org")

      expect{perform_login(new_user)}.must_change "User.count", 1
      expect(flash[:result_text]).must_equal "Welcome, #{new_user.username}!"
    end
  end

  describe "logout" do
    it "can logout as an existing user" do
      user = perform_login(users(:dan))

      expect(session[:user_id]).wont_be_nil

      post logout_path, params: {}

      expect(session[:user_id]).must_be_nil
      expect(flash[:result_text]).must_equal "Successfully logged out"
      must_redirect_to root_path
    end
  end
end
