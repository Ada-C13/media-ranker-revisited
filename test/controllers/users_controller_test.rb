require "test_helper"

describe UsersController do
  describe "login users#create" do
    it "can log in a new user through OAuth and increase User count" do
      new_user = User.new(provider: "github-test", uid: "777999", username: "goblin", email: "goblin@goblins.net")

      expect {
        @login_user = perform_login(new_user)
      }.must_differ "User.count", 1

      expect(session[:user_id]).must_equal @login_user.id
      must_respond_with :redirect
    end

    it "can log in an existing user through OAuth" do
      expect {
        @existing_user = perform_login(users(:dan))
      }.wont_change "User.count"

      expect(session[:user_id]).must_equal @existing_user.id
      must_respond_with :redirect
    end

    it "redirects with error message if given invalid user data" do
      invalid_user = User.new(provider: "github-test", uid: nil, username: "goblin", email: "goblin@goblins.net")

      expect {
        @login_user = perform_login(invalid_user)
      }.wont_change "User.count"

      expect(session[:user_id]).must_be_nil
      expect(flash[:status]).must_equal :failure
      expect(flash[:result_text]).must_equal "Could not log in"
      must_respond_with :redirect
    end
  end

  describe "logout" do
    it "can log out a user" do
      # first user logged in and in session
      perform_login
      expect(session[:user_id]).wont_be_nil

      post logout_path
      expect(session[:user_id]).must_be_nil
      must_respond_with :redirect
    end
  end

  describe "show" do
    it "will get show for valid user ids" do
      valid_user = users(:dan)
  
      get user_path(valid_user)
  
      must_respond_with :success
    end
  
    it "will render 404 for invalid user ids" do  
      get user_path(-1)
  
      must_respond_with :not_found
    end
  end
end
