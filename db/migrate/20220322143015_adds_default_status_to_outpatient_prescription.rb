class AddsDefaultStatusToOutpatientPrescription < ActiveRecord::Migration[5.2]
  def change
    change_column_default :outpatient_prescriptions, :status, from: nil, to: 0
  end
end
