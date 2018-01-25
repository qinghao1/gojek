class CreateDrivers < ActiveRecord::Migration[5.1]
  def change
    # Create Drivers table
    create_table :drivers do |t|
      t.st_point :lonlat, geographic: true
    end
    # Use spatial indexing
    change_table :drivers do |t|
      t.index :lonlat, using: :gist
    end
  end
end
