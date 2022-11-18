def roles_populate
  get_roles.each do |role_to_create|
    role = create(:role, name: role_to_create)
    if role_to_create == 'Dispensa de recetas'
      Permission.where(name: %w[create_patients
                                read_patients
                                read_professionals
                                create_professionals
                                read_products
                                read_stocks
                                create_archive_stocks
                                read_archive_stocks
                                return_archive_stocks
                                read_lot_stocks
                                read_movement_stocks
                                read_chronic_prescriptions
                                create_chronic_prescriptions
                                update_chronic_prescriptions
                                destroy_chronic_prescriptions
                                dispense_chronic_prescriptions
                                complete_treatment_chronic_prescriptions
                                return_chronic_prescriptions
                                read_outpatient_recipes
                                update_outpatient_recipes
                                dispense_outpatient_recipes
                                return_outpatient_recipes
                                destroy_outpatient_recipes
                                read_establishments
                                read_sectors]).each do |permission|
        PermissionRole.create(role_id: role.id, permission_id: permission.id)
      end
    end

    if role_to_create == 'Pedidos Internos'
      Permission.where(name: %w[create_patients
                                read_stocks
                                create_archive_stocks
                                read_archive_stocks
                                return_archive_stocks
                                read_lot_stocks
                                read_movement_stocks
                                read_internal_order_applicant
                                create_internal_order_applicant
                                update_internal_order_applicant
                                destroy_internal_order_applicant
                                send_internal_order_applicant
                                receive_internal_order_applicant
                                return_internal_order_applicant
                                read_internal_order_provider
                                create_internal_order_provider
                                update_internal_order_provider
                                destroy_internal_order_provider
                                send_internal_order_provider
                                nullify_internal_order_provider
                                return_internal_order_provider
                                read_establishments
                                read_sectors]).each do |permission|
        PermissionRole.create(role_id: role.id, permission_id: permission.id)
      end
    end

    if role_to_create == 'Pedidos Externos'
      Permission.where(name: %w[create_patients
                              read_stocks
                              create_archive_stocks
                              read_archive_stocks
                              return_archive_stocks
                              read_lot_stocks
                              read_movement_stocks
                              read_external_order_applicant
                              create_external_order_applicant
                              update_external_order_applicant
                              destroy_external_order_applicant
                              send_external_order_applicant
                              receive_external_order_applicant
                              return_external_order_applicant
                              destroy_external_order_provider
                              send_external_order_provider
                              nullify_external_order_provider
                              return_external_order_provider
                              accept_external_order_provider
                              read_establishments
                              read_sectors]).each do |permission|
        PermissionRole.create(role_id: role.id, permission_id: permission.id)
      end
    end
  end
end
