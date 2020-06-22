require "test_helper"

describe User do
  describe "relations" do
    it "has a list of votes" do
      dan = users(:diana)
      expect(dan).must_respond_to :votes
      dan.votes.each do |vote|
        expect(vote).must_be_kind_of Vote
      end
    end

    it "has a list of ranked works" do
      dan = users(:diana)
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

  describe "built_from_github" do
    it "creates a new user" do 
      auth_hash = {
        provider: "github",
        uid: 1115 ,
        "info" => {
          "nickname" => "whydidiprocrastinateonthis",
          "email" => "user@email.com"
        }
      }

      user = User.build_from_github(auth_hash)
      user.save!

      expect(User.count).must_equal 3

      expect(user.provider).must_equal auth_hash[:provider]
      expect(user.uid).must_equal auth_hash[:uid]
      expect(user.username).must_equal auth_hash["info"]["nickname"]
      expect(user.email).must_equal auth_hash["info"]["email"]
    end
  end
end
