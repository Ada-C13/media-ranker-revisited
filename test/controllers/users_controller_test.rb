require "test_helper"

describe UsersController do
  before do 
    @user = users(:grace)
    perform_login(@user)
  end
  describe "auth_callback" do
    
    let(:valid_user) {
      User.new(
        provider: "github",
        uid: 999967, 
        username: "Lak", 
        email: "lak@user.com"
      )
    }

    let(:invalid_user) {
      User.new(
        provider: "github",
        uid: 999998, 
        username: nil, 
        email: "test@user.com"
      )
    }

    it "logs in an existing user and redirects to the root route" do
      start_count = User.count

      must_redirect_to root_path

      # Since we can read the session, check that the user ID was set as expected
      session[:user_id].must_equal @user.id

      # Should *not* have created a new user
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
      start_count = User.count
      user = User.new(provider: "github", uid: 99999, username: nil, email: "test@user.com")

      perform_login(user)

      expect(flash[:error]).must_equal "Could not create new user account"
      must_redirect_to root_path 
      User.count.must_equal start_count 
    end
  end

  describe "logout" do
    it "can logout an existing user" do
      put logout_path, params: {}
      expect(session[:user_id]).must_be_nil
      must_redirect_to root_path
    end
  end
end
