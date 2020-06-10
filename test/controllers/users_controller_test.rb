require "test_helper"

describe UsersController do
  describe "login" do
    it "can login an existing user" do
      user = perform_login(users(:dan))

      must_respond_with :redirect
    end
    it "can login a new user" do
      new_user = User.new(username: "cheeese", provider: "github", avatar: "string", uid: 1111, email: "some@email.com")
      expect {
        logged_in_user = perform_login(new_user)
      }.must_change "User.count", 1

      must_respond_with :redirect
    end
  end
  describe "logout" do
    it "can logout an existing user" do
      perform_login
      expect(session[:user_id]).wont_be_nil
      post logout_path
      expect(session[:user_id]).must_be_nil
      must_respond_with :redirect
    end
    it "guest users on that route" do 
        #TODO:
    end
  end
end
