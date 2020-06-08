class User < ApplicationRecord
  has_many :votes
  has_many :ranked_works, through: :votes, source: :work

  validates :username, presence: true
  validates :provider, presence: true
  validates :uid, presence: true, uniqueness: true

end
