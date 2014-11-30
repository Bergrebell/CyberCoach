class CreateTracks < ActiveRecord::Migration
  def change
    create_table :tracks, force: true do |t|
      t.text :data
      t.string :format
      t.belongs_to :sport_session_participant
      t.belongs_to :user
      t.belongs_to :sport_session
      t.timestamps
    end
  end
end
