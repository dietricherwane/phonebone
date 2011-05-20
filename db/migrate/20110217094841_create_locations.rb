
class CreateLocations < ActiveRecord::Migration
  def self.up
    create_table :locations do |t|
      t.string   :name
      t.string   :address, :limit => 5000
      t.decimal  :longitude
      t.decimal  :latitude
      t.string   :email, :limit => 5000
      t.string   :telephone, :limit => 5000
      t.string   :fax, :limit => 5000
      t.string   :website, :limit => 5000
      t.timestamps
    end

    #add_column :locations, :feature, :geometry, :limit => nil, :srid => 4326
    #add_index "locations", ["feature"], :name => "idx_locations_feature", :spatial => true
    #add_index :locations, ["name"], :name => "idx_features_name"
  end

  def self.down
    drop_table :locations
  end
end
