class CreatesEstablishmentsPermissions < ActiveRecord::Migration[5.2]
  def change
    establishments = PermissionModule.create(name: 'Establecimientos')
    Permission.create(name: 'create_establishments', permission_module: establishments)
    Permission.create(name: 'read_establishments', permission_module: establishments)
    Permission.create(name: 'update_establishments', permission_module: establishments)
    Permission.create(name: 'destroy_establishments', permission_module: establishments)
  end
end
