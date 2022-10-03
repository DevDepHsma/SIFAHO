class CreatesReportsPermissions < ActiveRecord::Migration[5.2]
  def up
    reports = PermissionModule.create(name: 'Reportes')
    Permission.create(name: 'report_by_patients', permission_module: reports)
    Permission.create(name: 'report_by_sectors', permission_module: reports)
    Permission.create(name: 'report_by_establishments', permission_module: reports)
  end

  def down
    reports = PermissionModule.find_by(name: 'Reportes')
    Permission.where(permission_module: reports).destroy_all
    reports.destroy
  end
end
