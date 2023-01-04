class AddAllPatientColumnToReports < ActiveRecord::Migration[5.2]
  def up
    add_column :reports, :all_patients, :boolean, default: false
  end

  def down
    remove_column :reports, :all_patients, :boolean
  end
end
