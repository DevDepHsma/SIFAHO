class AddDispensedDateAndPrescriptionTypeToReportPatients < ActiveRecord::Migration[5.2]
  def up
    add_column :report_patients, :dispensed_date, :datetime
    add_column :report_patients, :prescription_type, :string
  end

  def down
    remove_column :report_patients, :dispensed_date, :datetime
    remove_column :report_patients, :prescription_type, :string
  end
end
