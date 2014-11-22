class ChangesInAchievementsModel < ActiveRecord::Migration
  def change
    remove_column :achievements, :category_id, :integer
    remove_column :achievements, :sport_id, :integer
    add_column :achievements, :sport, :string
    drop_table :sports
  end
end
