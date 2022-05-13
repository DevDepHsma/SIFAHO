class CreatesSanitaryZonePermissions < ActiveRecord::Migration[5.2]
  def change
    sanitary_zones = PermissionModule.create(name: 'Zonas Sanitarias')
    Permission.create(name: 'create_sanitary_zones', permission_module: sanitary_zones)
    Permission.create(name: 'read_sanitary_zones', permission_module: sanitary_zones)
    Permission.create(name: 'update_sanitary_zones', permission_module: sanitary_zones)
    Permission.create(name: 'destroy_sanitary_zones', permission_module: sanitary_zones)
  end
end
