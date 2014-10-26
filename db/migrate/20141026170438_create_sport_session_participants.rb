class CreateSportSessionParticipants < ActiveRecord::Migration
  def change
    create_table :sport_session_participants do |t|
      t.integer :user_id
      t.integer :sport_session_id
      t.boolean :confirmed

      t.timestamps
    end
  end
end
