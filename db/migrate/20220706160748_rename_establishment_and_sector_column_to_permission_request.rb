class RenameEstablishmentAndSectorColumnToPermissionRequest < ActiveRecord::Migration[5.2]
  def up
    rename_column :permission_requests, :establishment, :other_establishment
    rename_column :permission_requests, :sector, :other_sector
  end

  def down
    rename_column :permission_requests, :other_establishment, :establishment
    rename_column :permission_requests, :other_sector, :sector
  end
end
