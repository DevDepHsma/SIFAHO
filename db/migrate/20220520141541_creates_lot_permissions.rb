class CreatesLotPermissions < ActiveRecord::Migration[5.2]
  def change
    lots = PermissionModule.create(name: 'Lotes')
    Permission.create(name: 'create_lots', permission_module: lots)
    Permission.create(name: 'read_lots', permission_module: lots)
    Permission.create(name: 'update_lots', permission_module: lots)
    Permission.create(name: 'destroy_lots', permission_module: lots)
  end
end
