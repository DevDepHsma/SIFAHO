class CreatesLotProvenancePermissions < ActiveRecord::Migration[5.2]
  def change
    lots_provenance = PermissionModule.create(name: 'Procedencia de lotes')
    Permission.create(name: 'create_lots_provenance', permission_module: lots_provenance)
    Permission.create(name: 'read_lots_provenance', permission_module: lots_provenance)
    Permission.create(name: 'update_lots_provenance', permission_module: lots_provenance)
    Permission.create(name: 'destroy_lots_provenance', permission_module: lots_provenance)
  end
end
