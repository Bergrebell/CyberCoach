class CreateCyclingParticipantResults < ActiveRecord::Migration
  def change
    create_table :cycling_participant_results do |t|
      t.integer :sport_session_participant_id
      t.float :length
      t.float :time

      t.timestamps
    end
  end
end