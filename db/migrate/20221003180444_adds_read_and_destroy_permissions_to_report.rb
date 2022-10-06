class AddsReadAndDestroyPermissionsToReport < ActiveRecord::Migration[5.2]
  def up
    pm = PermissionModule.find_by(name: 'Reportes')
    Permission.create(name: 'read_reports', permission_module_id: pm.id)
    Permission.create(name: 'destroy_reports', permission_module_id: pm.id)
  end

  def down 
    Permission.find_by(name: 'read_reports').destroy
    Permission.find_by(name: 'destroy_reports').destroy
  end
end
