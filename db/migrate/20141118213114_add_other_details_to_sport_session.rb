class AddOtherDetailsToSportSession < ActiveRecord::Migration
  def change
    add_column :sport_sessions, :title, :string
    add_column :sport_sessions, :latitude, :float
    add_column :sport_sessions, :longitude, :float
  end
end
