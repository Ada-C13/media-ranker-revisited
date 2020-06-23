require "test_helper"

describe UsersController do
  describe "login" do 
    it "can log in existing user" do 
      user = perform_login(users(:dan))

      must_respond_with :redirect
    end 

    it "can login new user" do 
      new_user = User.new(uid: "23443", username: "stephanie", email: "stephanie@stephanie.com")

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

      post logout_path, params: {}
      
      expect(session[:user_id]).must_be_nil
      
      must_redirect_to root_path
    end 
  end 
end
