require "test_helper"

describe UsersController do
  describe "auth_callback" do
    it "logs in an existing user and redirects to the root route" do
      # Arrange
      start_count = User.count
      user = users(:grace)
      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(user))

      # Act
      get auth_callback_path(:github)

      # Assert
      must_redirect_to root_path
      User.count.must_equal start_count
      session[:user_id].must_equal user.id
    end

    it "creates an account for a new user and redirects to the root route" do
      # Arrange
      start_count = User.count
      user = User.new(provider: "github", uid: 99999, username: "test_user", email: "test@user.com")
      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(user))

      # Act
      get auth_callback_path(:github)

      # Assert
      must_redirect_to root_path
      User.count.must_equal start_count + 1
      session[:user_id].must_equal User.last.id
    end    

    it "redirects to the login route if given invalid user data" do
      # Arrange
      start_count = User.count
      user1 = users(:grace)
      user2 = User.new(provider: "github", uid: user1.uid, username: "test_user", email: "test@user.com")
      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(user2))

      # Act
      get auth_callback_path(:github)

      # Assert
      must_redirect_to root_path
      User.count.must_equal start_count
    end
  end

  describe "logout" do
    it "logs out and redirects to the root route" do
      # Arrange
      start_count = User.count
      user = users(:grace)
      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(user))
      get auth_callback_path(:github)

      # Act
      delete logout_path

      # Assert
      must_redirect_to root_path
      session[:user_id].must_be_nil
    end
  end
end