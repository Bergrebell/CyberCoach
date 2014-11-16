class AddDateAndLocationToSportSessions < ActiveRecord::Migration
  def change
    add_column :sport_sessions, :location, :string
    add_column :sport_sessions, :date, :datetime
  end
end
