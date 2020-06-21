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
    it "requires a provider, a uid, a username, and an email" do
      user = User.new
      expect(user.valid?).must_equal false
      expect(user.errors.messages).must_include :username
      expect(user.errors.messages).must_include :email
      expect(user.errors.messages).must_include :provider
      expect(user.errors.messages).must_include :uid
    end

    it "requires a unique UID within the same provider" do
      user1 = User.new(provider: "github-test", uid: "777999", username: "goblin", email: "goblin@goblins.net")
      # This must go through, so we use create!
      user1.save!

      user2 = User.new(provider: "github-test", uid: "777999", username: "goblin", email: "goblin@goblins.net")
      expect(user2.valid?).must_equal false
      expect(user2.errors.messages).must_include :uid

      user3 = User.new(provider: "google-test", uid: "777999", username: "goblin", email: "goblin@goblins.net")
      expect(user3.valid?).must_equal true
    end
  end
end
