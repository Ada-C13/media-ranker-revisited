require "test_helper"

describe UsersController do
  describe "login" do 
    it "can log in as an existing user" do
      user = perform_login(users(:dan))
      expect{user}.wont_change "User.count"
      expect(flash[:notice]).must_equal "Welcome back, #{user.username}!"
      must_respond_with :redirect
    end

    it "can log in as a new user" do
      new_user = User.new(uid:"11111", username: "Ross", provider: "github", avatar: "ppppppp", email: "ross@ada.org")

      expect{perform_login(new_user)}.must_change "User.count", 1
      expect(flash[:notice]).must_equal "Welcome, #{new_user.username}!"
    end
  end
end
