require "test_helper"

describe UsersController do

  describe 'login' do
    it 'allows an existing user to login' do
      user = perform_login(users(:devin))

      must_respond_with :redirect
    end

    it 'enables a new user to log in' do
      new_user = User.new(username: 'kaida', provider: 'github', uid: 3632)

      expect {
        logged_in_user = perform_login(new_user)
      }.must_change "User.count", 1
      must_respond_with :redirect
    end
  end

  describe "logout" do 
    it "can logout an existing user" do 
      expect {
        perform_logout
      }.wont_change "User.count"

      must_respond_with :redirect
      must_redirect_to root_path
      expect(session[:user_id]).must_be_nil
    end 
  end
end
