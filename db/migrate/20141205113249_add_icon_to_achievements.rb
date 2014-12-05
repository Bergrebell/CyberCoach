class AddIconToAchievements < ActiveRecord::Migration
  def change
    add_column :achievements, :icon, :string
  end
end