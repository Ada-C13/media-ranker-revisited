require "test_helper"

describe User do
  describe "relations" do
    it "has a list of votes" do
      sarah = users(:sarah)
      expect(sarah).must_respond_to :votes
      sarah.votes.each do |vote|
        expect(vote).must_be_kind_of Vote
      end
    end

    it "has a list of ranked works" do
      sarah = users(:sarah)
      expect(sarah).must_respond_to :ranked_works
      sarah.ranked_works.each do |work|
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

  describe "build from github" do
    it "successfully returns a new user" do
      auth_hash = {
        provider: "github",
        uid: 3022,
        info: {
          username: "amylovespenguins",
          email: "amythepenguin@gmail.com",
          name: "Amy"
        }
      }

      user = User.build_from_github(auth_hash)

      expect(user.provider).must_equal auth_hash[:provider]
      expect(user.uid).must_equal auth_hash[:uid]
      expect(user.username).must_equal auth_hash[:info][:username]
    end
  end
end
