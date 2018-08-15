class CreatePrescriptions < ActiveRecord::Migration[5.1]
  def change
    create_table :prescriptions do |t|
      t.text :observation
      t.datetime :date_received
      t.datetime :date_dispensed
      t.integer :status, default: 0
      t.datetime :prescribed_date
      t.datetime :expiry_date

      t.timestamps
    end
    add_reference :prescriptions, :professional, foreign_key: true
    add_reference :prescriptions, :patient, foreign_key: true
    add_column :prescriptions, :deleted_at, :datetime
    add_index :prescriptions, :deleted_at
  end
end
