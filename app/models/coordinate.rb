class Coordinate < ActiveRecord::Base
  validates_uniqueness_of :address
end
