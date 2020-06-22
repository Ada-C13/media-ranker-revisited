require "test_helper"

describe UsersController do
  describe "create" do
    let (:new_user) {
      User.new(
        uid: 1337,  
        provider: "github", 
        username: "username",
        name: "name",
        email: "email@email.com"
      )
    }

    it "can log in an existing user" do
      user = perform_login(users(:user1))
      
      expect {
        get github_login_path
      }.wont_differ "User.count"
      
      must_respond_with :redirect
    end
    
    it "can log in a new user" do
      expect {
        current_user = perform_login(new_user)
      }.must_differ "User.count", 1
      
      must_respond_with :redirect
    end

    it "will flash errors for invalid login" do
      new_user.username = nil
      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(new_user))
      
      expect {
        get auth_callback_path(:github)
      }.wont_differ "User.count"

      expect(flash[:status]).must_equal :failure
      expect(flash[:result_text]).must_include "Could not log in"
      expect(flash[:messages].first).must_include :username
      expect(flash[:messages].first).must_include ["can't be blank"]

      must_respond_with :redirect
    end
  end

  describe "destroy" do
    it "can logout an existing user" do
      perform_login
      expect(session[:user_id]).wont_be_nil
      
      expect {
        delete logout_path, params: {}
      }.wont_differ "User.count"
      expect(session[:user_id]).must_be_nil
    end
  end
end
