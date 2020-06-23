require "test_helper"

describe UsersController do

  describe "auth_callback" do
    it "logs in an existing user and redirects to the root route" do
      start_count = User.count
      user = users(:sarah)
      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(user))

      get omniauth_callback_path(:github)

      must_redirect_to root_path
      session[:user_id].must_equal user.id
      User.count.must_equal start_count
    end
  end

  describe 'login' do
    it 'allows an existing user to login' do
      user = perform_login(users(:devin))

      must_respond_with :redirect
    end

    it "enables a new user to log in" do
      new_user = User.new(username: "kaidasky", provider: "github", uid: 3632, email: "kaida@gmail.org", name: "kaida")

      expect {
        logged_in_user = perform_login(new_user)
      }.must_change "User.count", 1
      must_respond_with :redirect
    end
  end

  describe "logout" do 
    it "can logout an existing user" do 
      expect {
        post logout_path
      }.wont_change "User.count"

      must_respond_with :redirect
      must_redirect_to root_path
      expect(session[:user_id]).must_be_nil
    end 
  end
end
