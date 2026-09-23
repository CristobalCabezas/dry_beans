class CreateDeliveryEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :delivery_events do |t|
      t.references :trip, null: false, foreign_key: true
      t.integer :event_type, null: false
      t.integer :status, null: false
      t.string :recipient_name, null: false
      t.string :address, null: false
      t.datetime :scheduled_at
      t.datetime :completed_at
      t.text :notes

      t.timestamps
    end
  end
end
