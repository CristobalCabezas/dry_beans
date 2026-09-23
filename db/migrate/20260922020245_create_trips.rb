class CreateTrips < ActiveRecord::Migration[8.1]
  def change
    create_table :trips do |t|
      t.references :route, null: false, foreign_key: true
      t.integer :sequence, null: false
      t.string :driver_name, null: false
      t.integer :status, null: false

      t.timestamps
    end
  end
end
