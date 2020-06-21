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

  describe "build_from_github" do
    it "stores a new User instance that has attributes: username, email, provider, and uid" do
      test_hash = {
        "provider" => "github-test",
        "uid" => 520,
        "info" => {
          "email" => "test@test.org",
          "nickname" => "testtt",
        },
      }

      result_user = User.build_from_github(test_hash)
      expect(result_user).must_be_instance_of User
      expect(result_user.valid?).must_equal true

      expect(result_user.id).must_be_nil  # the User is not saved to db in this method   
      expect(result_user).must_respond_to :username
      expect(result_user).must_respond_to :email
      expect(result_user).must_respond_to :provider
      expect(result_user).must_respond_to :uid
    end

    it "stores a new User instance with incomplete attributes if given insufficient data" do
      test_hash = {
        "provider" => "github-test",
        "uid" => 520,
        "info" => {
          "email" => "test@test.org",
          "nickname" => nil,
        },
      }

      result_user = User.build_from_github(test_hash)
      expect(result_user).must_be_instance_of User
      expect(result_user.valid?).must_equal false
      
      expect(result_user).must_respond_to :username
      expect(result_user).must_respond_to :email
      expect(result_user).must_respond_to :provider
      expect(result_user).must_respond_to :uid
    end
  end
end
