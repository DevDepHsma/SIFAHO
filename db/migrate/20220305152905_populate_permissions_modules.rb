class PopulatePermissionsModules < ActiveRecord::Migration[5.2]
  def change
    # User permissions
    permission_module = PermissionModule.create(name: 'Usuario')
    Permission.create(name: 'read_users', permission_module: permission_module)
    Permission.create(name: 'update_permissions', permission_module: permission_module)

    # # Outpatient permissions
    recipes_permission_module = PermissionModule.create(name: 'Recetas Ambulatorias')
    Permission.create(name: 'read_outpatient_recipes', permission_module: recipes_permission_module)
    Permission.create(name: 'update_outpatient_recipes', permission_module: recipes_permission_module)
    Permission.create(name: 'dispense_outpatient_recipes', permission_module: recipes_permission_module)
    Permission.create(name: 'return_outpatient_recipes', permission_module: recipes_permission_module)
    Permission.create(name: 'destroy_outpatient_recipes', permission_module: recipes_permission_module)

    # Chronic Prescriptions
    chronic_permission_module = PermissionModule.create(name: 'Recetas Crónicas')
    Permission.create(name: 'read_chronic_prescriptions', permission_module: chronic_permission_module)
    Permission.create(name: 'create_chronic_prescriptions', permission_module: chronic_permission_module)
    Permission.create(name: 'update_chronic_prescriptions', permission_module: chronic_permission_module)
    Permission.create(name: 'destroy_chronic_prescriptions', permission_module: chronic_permission_module)
    Permission.create(name: 'dispense_chronic_prescriptions', permission_module: chronic_permission_module)
    Permission.create(name: 'complete_treatment_chronic_prescriptions', permission_module: chronic_permission_module)
    Permission.create(name: 'return_chronic_prescriptions', permission_module: chronic_permission_module)

    # # Professional
    professionals_permission_module = PermissionModule.create(name: 'Profesionales')
    Permission.create(name: 'read_professionals', permission_module: professionals_permission_module)
    Permission.create(name: 'create_professionals', permission_module: professionals_permission_module)
    Permission.create(name: 'update_professionals', permission_module: professionals_permission_module)
    Permission.create(name: 'destroy_professionals', permission_module: professionals_permission_module)

    # Internal Order Applicant 
    internal_order_applicant_module = PermissionModule.create(name: 'Ordenes Internas Solicitud')
    Permission.create(name: 'read_internal_order_applicant', permission_module: internal_order_applicant_module)
    Permission.create(name: 'create_internal_order_applicant', permission_module: internal_order_applicant_module)
    Permission.create(name: 'update_internal_order_applicant', permission_module: internal_order_applicant_module)
    Permission.create(name: 'destroy_internal_order_applicant', permission_module: internal_order_applicant_module)
    Permission.create(name: 'send_internal_order_applicant', permission_module: internal_order_applicant_module)
    Permission.create(name: 'receive_internal_order_applicant', permission_module: internal_order_applicant_module)
    Permission.create(name: 'return_internal_order_applicant', permission_module: internal_order_applicant_module)

    # Internal Order Provider 
    internal_order_provider_module = PermissionModule.create(name: 'Ordenes Internas Proveedor')
    Permission.create(name: 'read_internal_order_provider', permission_module: internal_order_provider_module)
    Permission.create(name: 'create_internal_order_provider', permission_module: internal_order_provider_module)
    Permission.create(name: 'update_internal_order_provider', permission_module: internal_order_provider_module)
    Permission.create(name: 'destroy_internal_order_provider', permission_module: internal_order_provider_module)
    Permission.create(name: 'send_internal_order_provider', permission_module: internal_order_provider_module)
    Permission.create(name: 'nullify_internal_order_provider', permission_module: internal_order_provider_module)
    Permission.create(name: 'return_internal_order_provider', permission_module: internal_order_provider_module)

    # External Order Applicant 
    external_order_applicant_module = PermissionModule.create(name: 'Ordenes Externas Solicitud')
    Permission.create(name: 'read_external_order_applicant', permission_module: external_order_applicant_module)
    Permission.create(name: 'create_external_order_applicant', permission_module: external_order_applicant_module)
    Permission.create(name: 'update_external_order_applicant', permission_module: external_order_applicant_module)
    Permission.create(name: 'destroy_external_order_applicant', permission_module: external_order_applicant_module)
    Permission.create(name: 'send_external_order_applicant', permission_module: external_order_applicant_module)
    Permission.create(name: 'receive_external_order_applicant', permission_module: external_order_applicant_module)
    Permission.create(name: 'return_external_order_applicant', permission_module: external_order_applicant_module)

    # External Order Provider 
    external_order_provider_module = PermissionModule.create(name: 'Ordenes Externas Proveedor')
    Permission.create(name: 'read_external_order_provider', permission_module: external_order_provider_module)
    Permission.create(name: 'create_external_order_provider', permission_module: external_order_provider_module)
    Permission.create(name: 'update_external_order_provider', permission_module: external_order_provider_module)
    Permission.create(name: 'destroy_external_order_provider', permission_module: external_order_provider_module)
    Permission.create(name: 'send_external_order_provider', permission_module: external_order_provider_module)
    Permission.create(name: 'nullify_external_order_provider', permission_module: external_order_provider_module)
    Permission.create(name: 'return_external_order_provider', permission_module: external_order_provider_module)
  end
end
