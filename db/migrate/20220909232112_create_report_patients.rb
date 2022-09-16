class CreateReportPatients < ActiveRecord::Migration[5.2]
  def up
    create_table :report_patients do |t|
      t.references :report, index: true, foreign_key: { to_table: :reports }
      t.references :product, index: true, foreign_key: { to_table: :products }
      t.references :patient, index: true, foreign_key: { to_table: :patients }
      t.integer :product_code
      t.string :product_name
      t.integer :product_quantity
      t.integer :patient_dni
      t.string :patient_full_name
      t.integer :patient_age
      t.date :patient_birthdate
      t.timestamps
    end
  end

  def down
    drop_table :report_patients
  end
end
