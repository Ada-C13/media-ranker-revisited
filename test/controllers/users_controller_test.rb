require "test_helper"

describe UsersController do
  let(:existing_user) { users(:ada) }

  describe "index" do
    it "succeeds when there are users" do
      get users_path
      must_respond_with :success
    end

    it "succeeds when there are no users" do
      User.all do |work|
        user.destroy
      end
      get users_path
      must_respond_with :success
    end
  end

  describe "show" do
    it "successfully retrieves show page for existing user" do
      get user_path(existing_user.id)
      must_respond_with :success
    end

    it "renders 404 when retrieving a page for a nonexistent user" do
      get user_path("fake_id")
      must_respond_with :not_found
    end
  end

  describe "create" do

    it "logs in a new user" do
      new_user = User.new(
        provider: "github",
        uid: 12346,
        email: "picchu@picchuemail.com",
        username: "peachbun",
        name: "Picchu Doggo",
      )

      expect {
        new_user = perform_login(new_user)
      }.must_change "User.count", 1

      expect(flash[:result_text]).must_equal "Logged in as new user #{new_user.username}"
      must_redirect_to root_path
      session[:user_id].must_equal new_user.id
    end

    it "logs in a returning user" do
      expect {
        perform_login(existing_user)
      }.wont_change "User.count"

      must_redirect_to root_path
      expect(session[:user_id]).must_equal existing_user.id
    end

    it "does not create a user account for malformed requests" do
      invalid_user = User.new(
        uid: nil, 
        username: nil, 
        provider: "github", 
        email: "something.com")

      perform_login(invalid_user)
      invalid_user.valid?
      expect(flash[:result_text]).must_equal "Could not create new user account."
    end
  end

  describe "logout" do
    it "removes the user from session" do
      perform_login
      expect(session[:user_id]).wont_be_nil

      post logout_user_url(session[:user_id])
      expect(session[:user_id]).must_be_nil
      expect(flash[:result_text]).must_equal "Successfully logged out!"

      must_redirect_to root_path
    end
  end
end
