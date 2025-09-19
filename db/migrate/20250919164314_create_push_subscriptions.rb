class CreatePushSubscriptions < ActiveRecord::Migration[8.0]
  def change
    create_table :push_subscriptions do |t|
      t.references :user, null: false, foreign_key: true
      t.string :endpoint
      t.string :public_key
      t.string :auth_secret
      t.datetime :expires_at, null: true

      t.timestamps
    end

    add_index :push_subscriptions, [ :user_id, :endpoint, :public_key, :auth_secret ], unique: true, if_not_exists: true, name: 'index_push_subscriptions_on_user_id_endpoint_and_auth'
  end
end
