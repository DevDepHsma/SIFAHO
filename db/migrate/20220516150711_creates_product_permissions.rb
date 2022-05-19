class CreatesProductPermissions < ActiveRecord::Migration[5.2]
  def change
    products = PermissionModule.create(name: 'Productos')
    Permission.create(name: 'create_products', permission_module: products)
    Permission.create(name: 'read_products', permission_module: products)
    Permission.create(name: 'update_products', permission_module: products)
    Permission.create(name: 'destroy_products', permission_module: products)
  end
end