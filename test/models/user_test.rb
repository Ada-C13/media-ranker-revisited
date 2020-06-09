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
      user = User.new(uid: 123, provider: 'provider')
      expect(user.valid?).must_equal false
      expect(user.errors.messages).must_include :username
    end
    
    it "requires a uid" do
      user = User.new(username: 'leah', provider: 'provider')
      expect(user.valid?).must_equal false
      expect(user.errors.messages).must_include :uid
    end
    
    it "requires a unique uid" do
      uid = 12345
      user1 = User.new(uid: uid, username: 'Leah', provider: 'provider')
      user1.save!
      
      user2 = User.new(uid: uid)
      result = user2.save
      expect(result).must_equal false
      expect(user2.errors.messages).must_include :uid
    end
    
    it 'requires a provider' do
      user = User.new(uid: 123, username: 'katie')
      expect(user.valid?).must_equal false
      expect(user.errors.messages).must_include :provider
    end
  end
  
  describe 'build from github' do
    it 'returns a new user' do
      auth_hash = {
        provider: 'github',
        uid: 1234,
        info: {
          nickname: 'Leah',
          email: 'leah@who.me'
        }
      }
      
      user = User.build_from_github(auth_hash)
      
      expect(user).must_be_kind_of User
      expect(user.provider).must_equal auth_hash[:provider]
      expect(user.uid).must_equal auth_hash[:uid]
      expect(user.username).must_equal auth_hash[:info][:nickname]
    end
  end
end