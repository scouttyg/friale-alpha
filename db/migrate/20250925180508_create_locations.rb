class CreateLocations < ActiveRecord::Migration[8.0]
  def change
    create_table :locations do |t|
      t.string :city
      t.string :region
      t.string :country
      t.string :time_zone
      t.float :latitude
      t.float :longitude
      t.string :slug

      t.timestamps
    end
  end
end
