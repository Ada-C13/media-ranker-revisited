require "test_helper"

describe UsersController do
  describe 'login' do 
    it 'can log in an existing user' do
      user = perform_login(users(:dee))

      must_respond_with :redirect
    end
  end
end
