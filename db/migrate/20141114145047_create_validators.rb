class CreateValidators < ActiveRecord::Migration
  def change
    create_table :validators do |t|
      t.string :type

      t.timestamps
    end
  end
end
