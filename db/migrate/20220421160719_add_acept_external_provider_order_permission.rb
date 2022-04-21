class AddAceptExternalProviderOrderPermission < ActiveRecord::Migration[5.2]
  def change
    external_order_provider_module = PermissionModule.find_by(name: 'Ordenes Externas Proveedor')
    Permission.create(name: 'accept_external_order_provider', permission_module: external_order_provider_module)
  end
end
