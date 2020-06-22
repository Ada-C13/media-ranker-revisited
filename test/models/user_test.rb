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
      user1 = User.new(username: username, uid: 7)

      # This must go through, so we use create!
      user1.save!

      user2 = User.new(username: username)
      result = user2.save
      expect(result).must_equal false
      expect(user2.errors.messages).must_include :username
    end

    it "requires a unique uid" do

      ada = users(:ada)

      dup_ada = User.new(
				provider: ada.provider,
				uid: ada.uid,
				email: ada.email,
				username: ada.username,
				name: ada.name
      )

      result = dup_ada.save
      expect(result).must_equal false
      expect(dup_ada.errors.messages).must_include :uid
      expect([User.find_by(uid: ada.uid)].length).must_equal 1
    end
  end
end
