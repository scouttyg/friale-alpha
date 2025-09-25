class AddMetadataToAccount < ActiveRecord::Migration[8.0]
  def change
    add_column :accounts, :metadata, :jsonb
  end
end
