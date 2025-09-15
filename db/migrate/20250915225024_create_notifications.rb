class CreateNotifications < ActiveRecord::Migration[8.0]
  def change
    create_table :notifications do |t|
      t.text :body
      t.datetime :read_at
      t.string :title
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
