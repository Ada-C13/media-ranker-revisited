require "test_helper"

describe UsersController do
  describe "auth_callback" do 
    it "can log in an existing user" do 
      user = login(users(:ada))

      must_respond_with :redirect 
    end 

    it "logs in an existing user" do
      start_count = User.count
      user = users(:ada)
    
      login(user)
      must_redirect_to root_path
      session[:user_id].must_equal user.id
      User.count.must_equal start_count
    end

    it "can login new user" do 
      new_user = User.new( uid:9876, username:"oscar", email: "oscar@gmail.org", provider: "github")

      expect {
        login(new_user)
      }.must_change "User.count", 1 
     
      must_respond_with :redirect 
    end 
  end 


  describe "logout" do 
    it "can logout " do 
      
      login()
      expect(session[:user_id]).wont_be_nil

      post logout_path

      expect(session[:user_id]).must_be_nil

    end 
  end 





end
