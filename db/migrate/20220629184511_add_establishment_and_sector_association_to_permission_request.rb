class AddEstablishmentAndSectorAssociationToPermissionRequest < ActiveRecord::Migration[5.2]
  def up
    add_reference :permission_requests, :establishment, index: true
    add_reference :permission_requests, :sector, index: true
  end

  def down
    remove_reference :permission_requests, :establishment, index: true
    remove_reference :permission_requests, :sector, index: true
  end
end
