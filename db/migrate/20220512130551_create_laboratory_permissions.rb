class CreateLaboratoryPermissions < ActiveRecord::Migration[5.2]
  def change
    laboratory = PermissionModule.create(name: 'Laboratorios')
    Permission.create(name: 'create_laboratories', permission_module: laboratory)
    Permission.create(name: 'read_laboratories', permission_module: laboratory)
    Permission.create(name: 'update_laboratories', permission_module: laboratory)
    Permission.create(name: 'destroy_laboratories', permission_module: laboratory)
  end
end
