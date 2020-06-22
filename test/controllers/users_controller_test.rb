require "test_helper"

describe UsersController do
  describe "index" do
    it "responds with success when user saved" do
      user = users(:dw)
      get users_path

      expect(User.count > 0).must_equal true
      must_respond_with :success     
    end
  end

  describe "create" do
    it "logs in existing user, redirects to root" do
      count = User.count
      user = users(:dw)
      login(user)

      expect(flash[:success]).must_equal "Logged in as returning user #{user.name}"
      session[:user_id].must_equal user.id
      must_redirect_to root_path
      User.count.must_equal count
    end

    it "creates account for new user, redirects to root" do
      count = User.count
      user = User.new(provider: "github", uid: 12347, username: "hannah_montana", email: "hannah_montana@montana.com", name: "Hannah")
      login(user)
      
      expect(flash[:success]).must_equal "Logged in as new user #{user.name}"
      session[:user_id].must_equal User.last.id
      must_redirect_to root_path
      User.count.must_equal start_count + 1
    end

    it "redirects to login route if given bad data" do
      count = User.count
      bad_data = User.create(provider: "github", uid: 1232)
      login(user)

      expect(flash[:error]).must_include "Could not create new user account: "
      must_redirect_to root_path
      assert_nil(session[:user_id])
      User.count.must_equal start_count
    end
  end

  describe "show" do
    it "responds with success when showing a valid user" do
      test_user = users(:arthur)  
      get user_path(test_user.id)
      
      must_respond_with :success
    end
    
    it "redirects to users path if given invalid user id" do
      invalid_id = -1
      get user_path(invalid_id)
      
      must_respond_with :not_found
    end
  end
end
