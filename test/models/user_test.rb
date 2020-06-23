require "test_helper"

describe User do
  describe "relations" do
    it "has a list of votes" do
      ada = users(:ada)
      expect(ada).must_respond_to :votes
      ada.votes.each do |vote|
        expect(vote).must_be_kind_of Vote
      end
    end

    it "has a list of ranked works" do
      ada = users(:ada)
      expect(ada).must_respond_to :ranked_works
      ada.ranked_works.each do |work|
        expect(work).must_be_kind_of Work
      end
    end
  end

  describe "validations" do
    it "requires a username" do
      user = User.new
      expect(user.valid?).must_equal false
      expect(user.errors.messages).must_include :username
    end

    it "requires a unique username" do
      username = "test username"
      user1 = User.new(username: username)

      # This must go through, so we use create!
      user1.save!

      user2 = User.new(username: username)
      result = user2.save
      expect(result).must_equal false
      expect(user2.errors.messages).must_include :username
    end
  end

  describe "create_user_from_github" do 
    it "creates a valid user with a valid auth hash" do 
      mock_auth_hash = {"uid" => 1, "provider" => 'github', "info" => {"name" => "Test", "email" => "test@test.com"}}
      
      user = User.build_from_github(mock_auth_hash)
      user.save
      expect(user).must_be_kind_of User
      expect(user.nil?).must_equal false
    end 

    it "creates a valid user even if auth hash doesn't provide access to name" do 
      mock_auth_hash = {"uid" => 1, "provider" => 'github', "info" => {"email" => "test@test.com"}}
      
      user = User.build_from_github(mock_auth_hash)
      user.save
      expect(user).must_be_kind_of User
      expect(user.nil?).must_equal false
    end 
  end 
  
end
