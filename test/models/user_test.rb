require "test_helper"

describe User do
  describe "relations" do
    let(:dan) { users(:dan) }

    it "has a list of votes" do
      expect(dan).must_respond_to :votes
      dan.votes.each do |vote|
        expect(vote).must_be_kind_of Vote
      end
    end

    it "has a list of ranked works" do
      expect(dan).must_respond_to :ranked_works
      dan.ranked_works.each do |work|
        expect(work).must_be_kind_of Work
      end
    end
  end

  describe "validations" do
    let(:user) { User.new }
    
    it "requires a username" do
      expect(user.valid?).must_equal false
      expect(user.errors.messages).must_include :username
    end

    it "requires a unique username" do
      name = "test username"
      user.username = name

      user.save!

      user2 = User.new(username: name)
      result = user2.save
      expect(result).must_equal false
      expect(user2.errors.messages).must_include :username
    end
  end

  describe 'build_from_github' do
    it 'will build a user from a oath hash' do
      oath_hash = {uid: 99999, 'info' => {'nickname' => 'bob'}}
      new_user = User.build_from_github(oath_hash)
      expect( new_user ).must_be_kind_of User
      expect( new_user.username ).must_equal 'bob'
      expect( new_user.provider ).must_equal 'github'
      expect( new_user.uid ).must_equal 99999
    end
  end
end
