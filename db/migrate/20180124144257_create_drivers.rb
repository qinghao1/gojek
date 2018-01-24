class CreateDrivers < ActiveRecord::Migration[5.1]
  def change
    create_table :drivers do |t|
      t.st_point :lonlat, geographic: true
    end
  end
end
