require "test_helper"

describe UsersController do
  describe 'login' do 
    it 'can log in an existing user' do
      user = perform_login(users(:ada))

      must_respond_with :redirect
    end

    it 'can log in a new user' do
      new_user = User.new(
        uid: '18879545',
        username: 'HarryPotter',
        provider: 'github',
        avatar: "https://avatars3.githubusercontent.com/u/59400719?s=200&v=4",
        email: 'harrypotter@ada.edu',
        )

        expect {
          logged_in_user = perform_login(new_user)
        }.must_change "User.count", 1

        must_respond_with :redirect
    end
  end

  describe 'current' do
    it 'return 200 OK for a logged-in user' do
      perform_login(users(:ada))

      get user_path(users(:ada).id)

      must_respond_with :success
    end
  end

  describe 'logout' do
    it 'can logout a logged in user' do
      perform_login(users(:sharon))
      expect(session[:user_id]).wont_be_nil

      post logout_path

      expect(session[:user_id]).must_be_nil
      must_redirect_to root_path
    end

    it "guest users won't be able to log out without logged in "
    end
  end
end
