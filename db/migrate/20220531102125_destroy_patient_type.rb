class DestroyPatientType < ActiveRecord::Migration[5.2]
  def up
    remove_reference :patients, :patient_type, index: true
    drop_table :patient_types
  end

  def down
    create_table :patient_types do |t|
      t.string :name
      t.string :description

      t.timestamps
    end
    add_reference :patients, :patient_type, index: true, default: 1
  end
end
