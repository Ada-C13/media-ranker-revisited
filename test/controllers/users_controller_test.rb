require "test_helper"

describe UsersController do

  describe 'login' do
    it 'can login an existing user' do
      user = perform_login(users(:kari))

      must_respond_with :redirect
    end

    it 'can login a new user' do
      new_user = User.new(username: 'leah', provider: 'github', uid: 123456789)

      expect {
        logged_in_user = perform_login(new_user)
      }.must_change "User.count", 1

      must_respond_with :redirect
    end
  end

  describe "logout" do
    it 'can log out an existing user' do
    perform_login
    expect(session[:user_id]).wont_be_nil

    post logout_path, params: {}
    expect(session[:user_id]).must_be_nil
    must_redirect_to root_path
    end

    it 'redirects to root path if a guest/non-logged in user tries to logout' do
      post logout_path, params: {}

      must_redirect_to root_path
    end
  end

  # describe 'logged in user access' do
    

  #   it 'logged in user can access the homepage (root)' do
     
  #   end

  #   it 'logged in user can see all works (index)' do
   
  #   end

  #   it 'logged in user can create a new work (create)' do

  #   end

  #   it 'logged in user can see individual work (show)' do

  #   end

  #   it 'logged in user can update existing work (update)' do

  #   end

  #   it 'logged in user can destroy existing work (destroy)' do

  #   end

  #   it 'logged in user can upvote existing work (upvote)' do

  #   end
    
  # end

  # describe 'guest user access' do

  #   it 'guest user can access the homepage (root)' do

  #   end

  #   it 'guest user cannot see all works (index)' do

  #   end

  #   it 'guest user cannot create a new work (create)' do

  #   end

  #   it 'guest user cannot see individual work (show)' do

  #   end

  #   it 'guest user cannot update existing work (update)' do

  #   end

  #   it 'guest user cannot destroy existing work (destroy)' do

  #   end

  #   it 'guest user cannot upvote existing work (upvote)' do

  #   end
  # end

end
