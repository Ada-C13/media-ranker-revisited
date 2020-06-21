require "test_helper"

describe UsersController do
  before do 
    @user = users(:kari)
    perform_login(@user)
  end

  describe "create user from gethub" do
    let(:valid_user) {
      User.new(
        provider: "github",
        uid: "1234567",
        username: "tina",
        email:"tina@ada.org",
        )
    }
    let(:invalid_user) {
      User.new(
        provider: "github",
        uid: "1234567",
        username: nil,
        email:"tina@ada.org",
        )
    }
    
    it "logs in an existing user and redirects to the root route" do

      start_count = User.count

      user = users(:dan)
      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(user))

      # Send a login request for that user
      get auth_callback_path(:github)

      must_redirect_to root_path

      session[:user_id].must_equal user.id
      User.count.must_equal start_count
    end

    it "creates an account for a new user and redirects to the root route" do
      put logout_path, params: {}
      
      expect{logged_in_user = perform_login(valid_user)}.must_change "User.count", 1
      expect(flash[:result_text]).must_equal "Logged in as new user #{valid_user.username}"
      must_respond_with :redirect
      must_redirect_to root_path
    end

    it "redirects to the login route if given invalid user data" do
      put logout_path, params: {}
      
      expect{logged_in_user = perform_login(invalid_user)}.wont_change "User.count"
      expect(flash[:error]).must_equal  "Could not create new user account: {:username=>[\"can't be blank\"]}"
      must_respond_with :redirect
      must_redirect_to root_path
    end

    describe "logout" do
      it "will logout an existing user" do
        put logout_path, params: {}

        expect(session[:user_id]).must_be_nil
        expect(flash[:result_text]).must_equal "Successfully logged out"
        must_redirect_to root_path
      end
    end 
  end
end
