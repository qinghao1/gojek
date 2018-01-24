class Driver < ApplicationRecord
  validates_presence_of :id, :lonlat
end
