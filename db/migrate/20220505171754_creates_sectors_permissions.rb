class CreatesSectorsPermissions < ActiveRecord::Migration[5.2]
  def change
    sector = PermissionModule.create(name: 'Sectores')
    Permission.create(name: 'create_sectors', permission_module: sector)
    Permission.create(name: 'read_sectors', permission_module: sector)
    Permission.create(name: 'update_sectors', permission_module: sector)
    Permission.create(name: 'destroy_sectors', permission_module: sector)
    Permission.create(name: 'create_to_other_establishments', permission_module: sector)
    Permission.create(name: 'read_other_establishments', permission_module: sector)
  end
end
