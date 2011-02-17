class CreateLibraries < ActiveRecord::Migration
  def self.up
    create_table :libraries do |t|
      t.string   :name
      t.string   :address
      t.string   :telephone
      t.string   :fax
      t.string   :email
      t.string   :website
      t.timestamps
    end
  end

  def self.down
    drop_table :libraries
  end
end
