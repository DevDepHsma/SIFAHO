class CreatesStockPermissions < ActiveRecord::Migration[5.2]
  def change
    stocks = PermissionModule.create(name: 'Stock')
    Permission.create(name: 'read_stocks', permission_module: stocks)
    Permission.create(name: 'read_lot_stocks', permission_module: stocks)
    Permission.create(name: 'read_archive_stocks', permission_module: stocks)
    Permission.create(name: 'create_archive_stocks', permission_module: stocks)
    Permission.create(name: 'return_archive_stocks', permission_module: stocks)
  end
end
