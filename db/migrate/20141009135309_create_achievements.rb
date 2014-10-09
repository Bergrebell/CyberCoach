class CreateAchievements < ActiveRecord::Migration
  def change
    create_table :achievements do |t|
      t.string :title
      t.integer :points
      t.integer :category_id

      t.timestamps
    end
  end
end
