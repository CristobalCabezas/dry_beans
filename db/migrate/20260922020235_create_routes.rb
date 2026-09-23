class CreateRoutes < ActiveRecord::Migration[8.1]
  def change
    create_table :routes do |t|
      t.string :code, null: false
      t.date :route_date, null: false
      t.integer :status, null: false

      t.timestamps
    end
  end
end
