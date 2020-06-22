class AddUsersReferenceToWorks < ActiveRecord::Migration[6.0]
  def change
    add_reference :works, :user, foreign_key: true
  end
end
