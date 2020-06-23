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

    it "requires a unique username, uid, email" do
      username = "test username"
      user1 = users(:grace)

      # This must go through, so we use create!
      user1.save!

      user2 = User.new(
        provider: "github",
        uid: 13371337,
        email: "grace@hooper.net",
        username: "graceful_hopps",
        name: "grace"
      )
  
      expect(user2.save).must_equal false
      expect(user2.errors.messages).must_include :username
      expect(user2.errors.messages).must_include :uid
      expect(user2.errors.messages).must_include :email
    end

  end
end
