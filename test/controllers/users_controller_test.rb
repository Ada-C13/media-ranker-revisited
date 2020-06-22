require "test_helper"

describe UsersController do
  describe "login" do 
    it "can log in as existing user" do 
      count = User.all.length
      perform_login(users(:ada))

      expect(flash["status"]).must_equal :success 
      expect(flash["result_text"]).must_include "Logged in as returning user"
      expect(User.all.count).must_equal count

      must_respond_with :redirect
      must_redirect_to root_path
    end

    it "can log in as new user" do 
      count = User.all.length
      new_user = User.new(uid: "1112222", username: "Pengsoo", provider: "github", email: "pengsoo@adadev.com")

      expect {
        logged_in_user = perform_login(new_user)
      }.must_change "User.count", 1

      expect(flash["status"]).must_equal :success 
      expect(flash["result_text"]).must_include "Logged in as new user"
      expect(User.all.length).must_equal count + 1

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
      expect(flash["messages"][:username]).must_include "can't be blank"

      must_redirect_to root_path
    end
  end

  describe "logout" do 
    it "can logout as existing user" do
      # Arrange 
      perform_login(users(:ada)) 

      expect(session[:user_id]).wont_be_nil

      delete logout_path

      expect(session[:user_id]).must_be_nil 

      expect(flash["status"]).must_equal :success
      expect(flash["result_text"]).must_include "Successfully logged out!"

      must_redirect_to root_path
    end

    # TODO
    it "cannot logout as guest user" do 
      
      delete logout_path

      expect(flash[:status]).must_equal :failure 
      expect(flash[:result_text]).must_equal "You must log in to do that"

      expect(session[:user_id]).must_be_nil 
      must_redirect_to root_path
    end
  end
end
