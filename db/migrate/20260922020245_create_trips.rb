class CreateTrips < ActiveRecord::Migration[8.1]
  def change
    create_table :trips do |t|
      t.references :route, null: false, foreign_key: true
      t.integer :sequence
      t.string :driver_name
      t.integer :status

      t.timestamps
    end
  end
end
