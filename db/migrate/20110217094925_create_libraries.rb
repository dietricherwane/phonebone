class CreateLibraries < ActiveRecord::Migration
  def self.up
    create_table :libraries do |t|
      t.string   :name
      t.string   :address, :limit => 5000
      t.string   :telephone, :limit => 5000
      t.string   :fax, :limit => 5000
      t.string   :email, :limit => 5000
      t.string   :website, :limit => 5000
      t.timestamps
    end
  end

  def self.down
    drop_table :libraries
  end
end
