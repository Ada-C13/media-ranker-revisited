require "test_helper"

describe User do
  describe "relations" do
    it "has a list of votes" do
      user = users(:user1)
      expect(user).must_respond_to :votes
      user.votes.each do |vote|
        expect(vote).must_be_kind_of Vote
      end
    end

    it "has a list of ranked works" do
      user = users(:user1)
      expect(user).must_respond_to :ranked_works
      user.ranked_works.each do |work|
        expect(work).must_be_kind_of Work
      end
    end
  end

  describe "validations" do
    before do
      @user = User.new(
        uid: "0",
        username: "newuser",
        email: "newuser@test.com"
      )
    end

    it "requires a username" do
      @user.username = nil
      expect(@user.valid?).must_equal false
      expect(@user.errors.messages).must_include :username
    end

    it "requires a unique username" do
      @user.username = users(:user1).username
      
      result = @user.save
      expect(result).must_equal false
      expect(@user.errors.messages).must_include :username
    end

    it "requires a uid" do
      @user.uid = nil
      expect(@user.valid?).must_equal false
      expect(@user.errors.messages).must_include :uid
    end

    it "requires a unique uid" do
      @user.uid = users(:user1).uid
      
      result = @user.save
      expect(result).must_equal false
      expect(@user.errors.messages).must_include :uid
    end

    it "requires an email" do
      @user.email = nil
      expect(@user.valid?).must_equal false
      expect(@user.errors.messages).must_include :email
    end

    it "requires a unique email" do
      @user.email = users(:user1).email
      
      result = @user.save
      expect(result).must_equal false
      expect(@user.errors.messages).must_include :email
    end
  end

  describe "build from github" do
    let (:auth_hash) {
      {
        uid: 1337,  
        provider: "github", 
        info: {
          nickname: "username",
          name: "name",
          email: "email@email.com"
        }
      }
    }

    it "can successfully build a user from a given auth_hash" do
      user = User.build_from_github(auth_hash)

      expect(user.valid?).must_equal true
      expect(user.uid).must_equal auth_hash[:uid]
      expect(user.provider).must_equal auth_hash[:provider]
      expect(user.username).must_equal auth_hash[:info][:nickname]
      expect(user.name).must_equal auth_hash[:info][:name]
      expect(user.email).must_equal auth_hash[:info][:email]
    end
  end
end
