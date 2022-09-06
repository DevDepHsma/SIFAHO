class AddsDefaultPermissionRoles < ActiveRecord::Migration[5.2]
  def up
    Role.all.destroy_all
    dispense = Role.create(name: 'Dispensa de recetas')
    internal_order = Role.create(name: 'Pedidos Internos')
    external_order = Role.create(name: 'Pedidos Externos')

    # Patient | Professional | Chronic | Outpatient | Stock | Sector | Establishment
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
      PermissionRole.create(role_id: dispense.id, permission_id: permission.id)
    end

    # Stock | Sector | Establishment | Internal Orders
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
      PermissionRole.create(role_id: internal_order.id, permission_id: permission.id)
    end

    # Stock | Sector | Establishment | External Orders
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
      PermissionRole.create(role_id: external_order.id, permission_id: permission.id)
    end
  end
end
