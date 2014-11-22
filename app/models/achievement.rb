class Achievement < ActiveRecord::Base
  has_many :credits
  belongs_to :validator
end