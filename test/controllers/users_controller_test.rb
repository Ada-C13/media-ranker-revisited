require "test_helper"

describe UsersController do
  describe "auth_callback" do
    it "logs in an existing user and redirects to the root route" do
      
      start_count = User.count
      user = users(:tom)

      perform_login(user)
      must_redirect_to root_path
    
      expect(session[:user_id]).must_equal user.id
      
      # Should *not* have created a new user
      expect(User.count).must_equal start_count
    end

    it "creates an account for a new user and redirects to the root route" do

      start_count = User.count
      user = User.create(username: "chelsea", uid: 123456)

      perform_login(user)
      must_redirect_to root_path
    
      expect(session[:user_id]).must_equal user.id
      
      # Should *not* have created a new user
      expect(User.count).must_equal start_count + 1
    end

    it "redirects if given invalid merchant data" do
      new_user = User.new(username: "chelsea", uid: 123456)
      perform_login(new_user)
      must_redirect_to root_path
    end

    describe "logout" do
      it "can logout an existing user" do
        # Arrange
        perform_login
  
        expect(session[:user_id]).wont_be_nil
  
        post logout_path, params: {}
  
        expect(session[:user_id]).must_be_nil
        must_redirect_to root_path
      end
    
    end
  end
end
