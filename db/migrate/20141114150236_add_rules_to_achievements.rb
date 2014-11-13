class AddRulesToAchievements < ActiveRecord::Migration
  def change
    add_column :achievements, :rules, :text
  end
end
