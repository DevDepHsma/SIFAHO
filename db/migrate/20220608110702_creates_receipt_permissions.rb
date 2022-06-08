class CreatesReceiptPermissions < ActiveRecord::Migration[5.2]
  def change
    receipts = PermissionModule.create(name: 'Recibos')
    Permission.create(name: 'create_receipts', permission_module: receipts)
    Permission.create(name: 'read_receipts', permission_module: receipts)
    Permission.create(name: 'update_receipts', permission_module: receipts)
    Permission.create(name: 'destroy_receipts', permission_module: receipts)
    Permission.create(name: 'rollback_receipts', permission_module: receipts)
    Permission.create(name: 'receive_receipts', permission_module: receipts)
  end
end
