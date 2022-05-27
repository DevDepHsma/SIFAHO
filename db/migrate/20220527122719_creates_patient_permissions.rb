class CreatesPatientPermissions < ActiveRecord::Migration[5.2]
  def change
    patients = PermissionModule.create(name: 'Pacientes')
    Permission.create(name: 'create_patients', permission_module: patients)
    Permission.create(name: 'read_patients', permission_module: patients)
    Permission.create(name: 'update_patients', permission_module: patients)
    Permission.create(name: 'destroy_patients', permission_module: patients)
  end
end
