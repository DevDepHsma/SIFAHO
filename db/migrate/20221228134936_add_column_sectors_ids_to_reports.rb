class AddColumnSectorsIdsToReports < ActiveRecord::Migration[5.2]
  def up
    add_column :reports, :sectors_ids, :text
  end

  def down
    remove_column :reports, :sectors_ids, :text
  end
end
