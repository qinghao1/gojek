class Driver < ApplicationRecord
  validates_presence_of :id, :lonlat, :accuracy
  validates :id, numericality: {
    greater_than_or_equal_to: 1,
    less_than_or_equal_to: 50000,
  }
  validates :accuracy, numericality: {
    greater_than_or_equal_to: 0,
    less_than_or_equal_to: 1,
  }
end
