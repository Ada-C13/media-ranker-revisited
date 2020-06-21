require "test_helper"

describe UsersController do
    describe "login" do 
        it "can log in an existing user" do 
            user = perform_login(users(:sara))

            must_respond_with :redirect
        end 

        it "can log in a new user" do 
            new_user = User.new(uid: 1111, username: "BenNilsen", provider: "github", avatar: "photo", email: "mintmonkey@at.home")
            expect {
                logged_in_user = perform_login(new_user)
            }.must_change "User.count", 1

            must_respond_with :redirect
        end 

    end 

    describe "logout" do 
        it "can logout an existing user" do 
            expect {
                perform_logout
              }.wont_change "User.count"
        
              must_respond_with :redirect
              must_redirect_to root_path
              expect(session[:user_id]).must_be_nil
    
        end 
    end 
end
