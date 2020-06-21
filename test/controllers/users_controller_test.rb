require "test_helper"

describe UsersController do

  describe "controller -- auth callback function " do 
    it "will not increase count and login user" do 
      init_count =  User.count 
      user = users(:quin)
      mock_login(user)

      must_redirect_to root_path
      session[:user_id].must_equal user.id
      User.count.must_equal init_count
    end 



    it "create new user" do 
      init_count =  User.count 

      user = User.new(provider: "github", uid: 934, username: "test", email: "q@gmail.com")
      mock_login(user)

      must_redirect_to root_path
      User.count.must_equal init_count + 1

      session[:user_id].must_equal User.last.id
    end 

    it "will redirect if a user can't be logged in" do 

      user = User.new(provider: "github", uid: 934, email: "q@gmail.com")
      mock_login(user)
      user.errors.nil?.must_equal false
      
      must_redirect_to root_path
    end 

    it "will log out a user" do 
      user = users(:grace)
      mock_login(user)

      delete logout_path

      (session[:user_id].nil?).must_equal true 

    end 
  end 




end
