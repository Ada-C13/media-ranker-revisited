require "test_helper"

describe UsersController do

	describe "login" do
		it "can login a existing user" do
			start_count = User.count

			perform_login(users(:kari))
			must_respond_with :redirect

			User.count.must_equal start_count
		end

		it "can login a new user" do 
			new_user = User.new(
				provider: "github",
				uid: 22,
				email: "kari@gmail.com",
				username: "bingus",
				name: "leroy"
			)

			expect {
				perform_login(new_user)
			}.must_change "User.count", 1

			must_respond_with :redirect
		end
	end

	describe "logout" do
		it "can logout a user" do
			perform_login
			expect(session[:user_id]).wont_be_nil

			delete logout_path
			expect(session[:user_id]).must_be_nil

			must_respond_with :redirect
			must_redirect_to root_path
		end

		it "cannot logout if you are not logged in" do
			delete logout_path

			expect(flash[:status]).must_equal :unauthorized
      expect(flash[:error]).must_equal "No user logged in."
		end
	end
end
