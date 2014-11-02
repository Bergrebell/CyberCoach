class CreateSportSessions < ActiveRecord::Migration
  def change
    create_table :sport_sessions do |t|
      t.integer :user_id
      t.string :type
      t.string :cybercoach_uri

      t.timestamps
    end
  end
end
