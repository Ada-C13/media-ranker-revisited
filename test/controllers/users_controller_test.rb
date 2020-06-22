require "test_helper"

describe UsersController do
    describe "auth_callback" do
        it "logs in an existing user and redirects to the root route" do
          start_count = User.count
          user = users(:dan)
    
          perform_login(user)
    
          must_redirect_to root_path
          expect(session[:user_id]).must_equal user.id
          expect(User.count).must_equal start_count
        end
    
        it "creates an account for a new user and redirects to the root route" do
            start_count = User.count
            new_user = User.new(provider: "github", uid: 99999, username: "new_user", email: "new@user.com")

            expect {perform_login(new_user)}.must_equal start_count + 1
            expect(session[:user_id]).must_equal User.last.id
          
            must_redirect_to root_path
        end
    
        it "redirects to the login route if given invalid user data" do
            new_user = User.new(provider: "github", uid: 99999, username: nil, email: "new@user.com")
            expect {perform_login(new_user)}.wont_change "User.count"
            must_redirect_to root_path
        end
    end

    describe "logout" do
        it "logs user out and redirects" do 
            user = users(:dan)
    
            perform_login(user)
            delete logout_path
            
            expect(session[:user_id]).must_be_nil 
            must_redirect_to root_path
        end
    end
end
