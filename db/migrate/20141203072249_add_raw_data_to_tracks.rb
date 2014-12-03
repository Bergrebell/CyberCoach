class AddRawDataToTracks < ActiveRecord::Migration
  def change
    add_column :tracks, :raw_data, :text
  end
end
