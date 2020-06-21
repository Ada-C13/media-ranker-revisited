require "test_helper"

describe UsersController do
  describe "login" do 
    it "can log in as existing user" do 
      user = perform_login(users(:ada))

      expect(flash["status"]).must_equal :success 
      expect(flash["result_text"]).must_include "Logged in as returning user"

      must_respond_with :redirect
    end

    it "can log in as new user" do 
      new_user = User.new(uid: "1112222", username: "Pengsoo", provider: "github", email: "pengsoo@adadev.com")

      expect {
        logged_in_user = perform_login(new_user)
      }.must_change "User.count", 1

      expect(flash["status"]).must_equal :success 
      expect(flash["result_text"]).must_include "Logged in as new user"

      must_respond_with :redirect
    end

    # TODO
    it "cannot log in with an invalid user id" do 
      
      new_user = User.new(uid: "5556666", provider: "github", email: "faker@adadev.com")

      expect {
        perform_login(new_user)
      }.wont_change "User.count"

      expect(flash["status"]).must_equal :failure
      expect(flash["result_text"]).must_include "Could not create user account"

      must_redirect_to root_path
    end
  end

  describe "logout" do 
    it "can logout as existing user" do
      # Arrange 
      perform_login 

      expect(session[:user_id]).wont_be_nil

      delete logout_path

      expect(session[:user_id]).must_be_nil 

      expect(flash["status"]).must_equal :success
      expect(flash["result_text"]).must_include "Successfully logged out!"

      must_redirect_to root_path
    end

    # TODO
    # it "guest users on the route" do 
      
    #   delete logout_path

    #   expect(session[:user_id]).must_be_nil 
    #   must_redirect_to root_path
    # end
  end
end
