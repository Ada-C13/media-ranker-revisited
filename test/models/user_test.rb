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
    describe "build_from_github" do 
      it "is invalid without username" do 
        user = User.new(
          provider: "github",
          uid: 3875394857,
          email: "test@gmail.com",
        )

        expect(user.valid?).must_equal false 
        expect(user.errors.messages).must_include :username
      end

      it "username must be unique" do 
        user_one = users(:dan)
        user_two = User.new(
          provider: "github",
          uid: 3875394857,
          email: "test@gmail.com",
          username: "dan"
        )

        user_two.save
        expect(user_two.valid?).must_equal false 
        expect(user_two.errors.messages).must_include :username
      end
    end
  end
end
