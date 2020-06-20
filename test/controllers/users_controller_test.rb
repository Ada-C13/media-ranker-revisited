require "test_helper"

describe UsersController do
  describe "auth_callback" do 
    it "logs in an existing user and redirects to the root path" do 
      start_count = User.count 
      user = users(:dan)

      perform_login(user)
      expect(user).wont_be_nil
      must_redirect_to root_path
      expect(session[:user_id]).must_equal user.id 
      expect(User.count).must_equal start_count
    end

    it "creates a new user and redirects to the root path" do 
      start_count = User.count 
      user = User.new(
        provider: "github", 
        uid: 578634, 
        username: "test_user", 
        email: "test@gmail.com"
      )

      perform_login(user)
      expect(user).wont_be_nil
      must_redirect_to root_path
      expect(session[:user_id]).must_equal User.last.id 
      expect(User.count).must_equal start_count + 1
    end

    it "redirects to the root path if given invalid user data" do 
      start_count = User.count 
      user = User.new(
        provider: "github", 
        uid: 578634, 
        email: "test@gmail.com"
      )

      result = perform_login(user)
      must_redirect_to root_path
      expect(result).must_be_nil
      expect(session[:user_id]).must_be_nil
    end
  end

  describe "log out" do 
    it "successfully logs out logged-in user" do 
      user = users(:dan)

      perform_login(user)
      expect(user).wont_be_nil

      post logout_path, params: {}

      expect(session[:user_id]).must_be_nil
      must_redirect_to root_path
    end
  end
end
