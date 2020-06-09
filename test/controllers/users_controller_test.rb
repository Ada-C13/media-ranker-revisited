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

      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(user))

      get auth_callback_path(:github)
    
    

      must_redirect_to root_path
   
    
      #User.count.must_equal init_count + 1

      session[:user_id].must_equal User.last.id
    end 
  end 




end
