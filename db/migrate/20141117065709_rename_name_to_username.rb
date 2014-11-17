class RenameNameToUsername < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.rename :name, :username
    end
  end
end
