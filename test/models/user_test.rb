require "test_helper"

describe User do
  describe "relations" do
    it "has a list of votes" do
      dan = users(:dan)
      expect(dan).must_respond_to :votes
      dan.votes.each do |vote|
        expect(vote).must_be_kind_of Vote
      end
    end

    it "has a list of ranked works" do
      dan = users(:dan)
      expect(dan).must_respond_to :ranked_works
      dan.ranked_works.each do |work|
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

  describe "custom methods" do 
    describe "self.build_from_github" do 
      it "can build a user from github" do    
        auth_hash = {
          "uid" => 1234578910,
          "provider" => "github",
          "info" => {
            "nickname" => "sharon",
            "email" => "sharon@ada.edu",
            "image" => "some image"
          }
        }
        current_user = User.build_from_github(auth_hash)

        expect(current_user).must_be_kind_of User
        expect(current_user.uid).must_equal  auth_hash['uid']
        expect(current_user.provider).must_equal auth_hash['provider']
        expect(current_user.username).must_equal auth_hash['info']['nickname']
        expect(current_user.email).must_equal auth_hash['info']['email']
        expect(current_user.avatar).must_equal auth_hash['info']['image']
      end
    end
  end
end
