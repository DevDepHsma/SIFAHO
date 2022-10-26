class AddsProductsAndPatientsColumnToReports < ActiveRecord::Migration[5.2]
  def up
    add_column :reports, :from_date, :datetime
    add_column :reports, :to_date, :datetime
    add_column :reports, :products_ids, :string
    add_column :reports, :patients_ids, :string
  end

  def down
    remove_column :reports, :from_date, :datetime
    remove_column :reports, :to_date, :datetime
    remove_column :reports, :products_ids, :string
    remove_column :reports, :patients_ids, :string
  end
end
