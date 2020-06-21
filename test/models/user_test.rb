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

  describe "custom methods" do 
    describe "self.build_from_github" do 
      it "can build a user from github" do    
        auth_hash = {
          "uid" => 9876651,
          "provider" => "github",
          "info" => {
            "nickname" => "pengsoo",
            "email" => "pengsoo@ada.com",
            "image" => "random image"
          }
        }

        current_user = User.build_from_github(auth_hash)

        expect(current_user).must_be_kind_of User
        expect(current_user.uid).must_equal "9876651"
        expect(current_user.provider).must_equal "github"
        expect(current_user.username).must_equal "pengsoo"
        expect(current_user.email).must_equal "pengsoo@ada.com"
      end
    end
  end
end
