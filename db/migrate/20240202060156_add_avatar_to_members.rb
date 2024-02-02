class AddAvatarToMembers < ActiveRecord::Migration[7.1]
  def change
    add_column :members, :avatar, :text
  end
end
