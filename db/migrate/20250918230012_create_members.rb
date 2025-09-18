class CreateMembers < ActiveRecord::Migration[8.0]
  def change
    create_table :members do |t|
      t.integer :access_level
      t.string :invite_email
      t.string :invite_token
      t.references :source, polymorphic: true, null: false
      t.string :type
      t.references :creator, index: true, null: true, foreign_key: { to_table: :users }
      t.references :user, null: true, foreign_key: true

      t.timestamps
    end
  end
end
