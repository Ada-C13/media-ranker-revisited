require "test_helper"

describe Vote do
  describe "relations" do
    it "has a user" do
      v = votes(:four)
      expect(v).must_respond_to :user
      expect(v.user).must_be_kind_of User
    end

    it "has a work" do
      v = votes(:one)
      expect(v).must_respond_to :work
      expect(v.work).must_be_kind_of Work
    end
  end

  describe "validations" do
    let (:user1) { users(:user1) }
    let (:user2) { users(:user2) }
    let (:work1) { works(:album) }
    let (:work2) { works(:another_album) }

    it "allows one user to vote for multiple works" do
      vote1 = Vote.new(user: user1, work: work1)
      vote1.save!
      vote2 = Vote.new(user: user1, work: work2)
      expect(vote2.valid?).must_equal true
    end

    it "allows multiple users to vote for a work" do
      vote1 = Vote.new(user: user1, work: work2)
      vote1.save!
      vote2 = Vote.new(user: user2, work: work2)
      expect(vote2.valid?).must_equal true
    end

    it "doesn't allow the same user to vote for the same work twice" do
      vote1 = Vote.new(user: user1, work: work1)
      vote1.save!
      vote2 = Vote.new(user: user1, work: work1)
      expect(vote2.valid?).must_equal false
      expect(vote2.errors.messages).must_include :user
    end
  end
end
