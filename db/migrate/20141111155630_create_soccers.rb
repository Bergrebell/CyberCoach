class CreateSoccers < ActiveRecord::Migration
  def change
    create_table :soccers do |t|

      t.timestamps
    end
  end
end
