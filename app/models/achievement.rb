class Achievement < ActiveRecord::Base
  has_many :credits
  belongs_to :category
end
