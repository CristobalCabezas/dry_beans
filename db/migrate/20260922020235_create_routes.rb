class CreateRoutes < ActiveRecord::Migration[8.1]
  def change
    create_table :routes do |t|
      t.string :code
      t.date :route_date
      t.integer :status

      t.timestamps
    end
  end
end
