require "test_helper"

describe UsersController do
  describe "auth_callback" do

    it "logs in an existing user and redirects to the root route" do
      user = users(:grace)

      expect{perform_login(user)}.wont_change 'User.count'

      must_redirect_to root_path
      user_id = session[:user_id]
      user_id.must_equal user.uid
    end

    it "creates an account for a new user and redirects to the root route" do
      user = User.new(provider: "github", uid: 111111, name: "test_user", email: "test@user.com", username:"test_user123")

      expect{perform_login(user)}.must_differ 'User.count', 1

      must_redirect_to root_path
      user_id = session[:user_id]
      user_id.must_equal User.last.uid
      
    end

    it "redirects to the login route if given invalid user data" do
      user = User.new(provider: "github")

      expect{perform_login(user)}.wont_change 'User.count'

      must_redirect_to github_login_path
      user_id = session[:user_id]
      user_id.must_be_nil
    end
  end

  describe "logout" do
    it "can log out a logged in user" do
      user = users(:grace)
      perform_login(user)

      expect(session[:user_id]).must_equal user.uid
      perform_logout
      expect(session[:user_id]).must_be_nil

    end
  end
end
