class AddSportAndValidationToAchievements < ActiveRecord::Migration
  def change
    add_column :achievements, :sport_id, :integer
    add_column :achievements, :validator_id, :integer
  end
end
