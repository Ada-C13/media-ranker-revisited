class User < ApplicationRecord
  has_many :votes
  has_many :ranked_works, through: :votes, source: :work

  validates :uid, uniqueness: true, presence: true
  validates :username, presence: true
  
  def self.build_from_github(auth_hash)
    user = User.new
    user.uid = auth_hash["uid"]
    user.username = auth_hash["info"]["nickname"]
    user.email = auth_hash["info"]["email"]

    return user #not saved yet 
  end
end
