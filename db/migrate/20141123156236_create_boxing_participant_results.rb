class CreateBoxingParticipantResults < ActiveRecord::Migration
  def change
    create_table :boxing_participant_results do |t|
      t.integer :sport_session_participant_id
      t.boolean :knockout_opponent
      t.integer :number_of_rounds
      t.integer :points
      t.float :time

      t.timestamps
    end
  end
end