class AddStatusToPatient < ActiveRecord::Migration[5.2]
  def change
    add_column :patients, :status, :integer, default: 0
  end
end