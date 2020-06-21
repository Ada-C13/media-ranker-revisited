require "test_helper"

describe UsersController do
  describe "Logged in users" do
    it "can log in a existing user" do
      start_count = User.count
      user = users(:dan)

      perform_login(user)
      must_redirect_to root_path
      expect(session[:user_id]).must_equal user.id
      expect(User.count).must_equal start_count
      _(flash[:success]).wont_be_nil
    end
    it "creates an new account for a user and will redirect" do
      new_user = User.new(username: "Pat Pending", uid: "12345", email: "pp@pp.com", provider: "github")
      expect {
        logged_in_user = perform_login(new_user)
      }.must_change "User.count", 1

      must_redirect_to root_path
      expect(session[:user_id]).must_equal User.last.id
    end

    it "redirects if  can't log in user" do
      expect {
        perform_login(User.new)
      }.wont_change "User.count"
      must_redirect_to root_path
      expect(session[:user_id]).must_equal nil
    end
    describe "destory" do
      it "can logout a user" do
        user = users(:kari)
        perform_login(user)

        delete logout_path
        must_redirect_to root_path
      end
      it "cannot logout a user if not signed in" do
        delete logout_path
        must_redirect_to root_path
      end
    end
  end
end
