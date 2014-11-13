class Achievement < ActiveRecord::Base
  has_many :credits
  belongs_to :category
  belongs_to :validator
  belongs_to :sport
end