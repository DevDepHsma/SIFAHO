class CreatesReportsPermissions < ActiveRecord::Migration[5.2]
  def up
    reports = PermissionModule.create(name: 'Reportes')
    Permission.create(name: 'external_order_by_products', permission_module: reports)
    Permission.create(name: 'patients', permission_module: reports)
    Permission.create(name: 'sectors', permission_module: reports)
    Permission.create(name: 'establishments', permission_module: reports)
    Permission.create(name: 'consumption_by_month', permission_module: reports)
  end

  def down 
    reports = PermissionModule.find_by(name: 'Reportes')
    Permission.where(permission_module: reports).destroy_all
    reports.destroy
  end
end
