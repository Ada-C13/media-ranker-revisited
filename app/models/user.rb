class User < ApplicationRecord
  has_many :votes
  has_many :ranked_works, through: :votes, source: :work

  validates :username, uniqueness: true, presence: true

  def self.build_from_github(auth_hash)
    user = User.new

    # workaround for Github users that don't have their name shared
    if !auth_hash["info"]["name"].nil? 
      user.username = auth_hash["info"]["name"]
    elsif !auth_hash["info"]["nickname"].nil? 
      user.username = auth_hash["info"]["nickname"]
    else
      user.username = user.email = auth_hash["info"]["email"]
    end

    # can assume we always have access to email at this point
    user.email = auth_hash["info"]["email"]

    user.uid = auth_hash[:uid]
    user.provider = "github"

    # note: User will be saved in users#create
    return user
  end
end
