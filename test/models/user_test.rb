require "test_helper"

describe User do
  describe "relations" do
    it "has a list of votes" do
      grace = users(:grace)
      expect(grace).must_respond_to :votes
      grace.votes.each do |vote|
        expect(vote).must_be_kind_of Vote
      end
    end

    it "has a list of ranked works" do
      grace = users(:grace)
      expect(grace).must_respond_to :ranked_works
      grace.ranked_works.each do |work|
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
      user1 = User.new(username: username, uid:1234)

      # This must go through, so we use create!
      user1.save!

      user2 = User.new(username: username, uid:1234)
      result = user2.save
      expect(result).must_equal false
      expect(user2.errors.messages).must_include :username
    end
  end
end
