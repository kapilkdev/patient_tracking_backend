class CreateMembers < ActiveRecord::Migration[7.1]
  def change
    create_table :members do |t|
      t.text :first_name
      t.text :last_name
      t.integer :gender
      t.integer :age
      t.integer :role

      t.timestamps
    end
  end
end
