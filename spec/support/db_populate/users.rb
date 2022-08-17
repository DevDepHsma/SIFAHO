def user_populate(config)
  config.before(:all, type: :feature) do
    @establishment_type = create(:hospital_establishment_type)
    @iv_zone = create(:iv_sanitary_zone)
    @establishment = create(:establishment_1, sanitary_zone: @iv_zone, establishment_type: @establishment_type)
    @deposito = create(:sector_4, establishment: @establishment)
    @farmacia = create(:sector_1, establishment: @establishment)
    @user = create(:user_4, sector: @farmacia)
    @applicant_user = create(:user_1, sector: @farmacia)
    @provider_user = create(:user_2, sector: @deposito)

    @pm_ois = create(:permission_module, name: 'Ordenes Internas Solicitud')
    @read_internal_order_applicant = create(:permission, name: 'read_internal_order_applicant',
                                                         permission_module: @pm_ois)
    @create_internal_order_applicant = create(:permission, name: 'create_internal_order_applicant',
                                                           permission_module: @pm_ois)
    @update_internal_order_applicant = create(:permission, name: 'update_internal_order_applicant',
                                                           permission_module: @pm_ois)
    @destroy_internal_order_applicant = create(:permission, name: 'destroy_internal_order_applicant',
                                                            permission_module: @pm_ois)
    @send_internal_order_applicant = create(:permission, name: 'send_internal_order_applicant',
                                                         permission_module: @pm_ois)
    @receive_internal_order_applicant = create(:permission, name: 'receive_internal_order_applicant',
                                                            permission_module: @pm_ois)
    @return_internal_order_applicant = create(:permission, name: 'return_internal_order_applicant',
                                                           permission_module: @pm_ois)

    @pm_oip = create(:permission_module, name: 'Ordenes Internas Proveedor')
    @read_internal_order_provider = create(:permission, name: 'read_internal_order_provider',
                                                        permission_module: @pm_oip)
    @create_internal_order_provider = create(:permission, name: 'create_internal_order_provider',
                                                          permission_module: @pm_oip)
    @update_internal_order_provider = create(:permission, name: 'update_internal_order_provider',
                                                          permission_module: @pm_oip)
    @destroy_internal_order_provider = create(:permission, name: 'destroy_internal_order_provider',
                                                           permission_module: @pm_oip)
    @send_internal_order_provider = create(:permission, name: 'send_internal_order_provider',
                                                        permission_module: @pm_oip)
    @nullify_internal_order_provider = create(:permission, name: 'nullify_internal_order_provider',
                                                           permission_module: @pm_oip)
    @return_internal_order_provider = create(:permission, name: 'return_internal_order_provider',
                                                          permission_module: @pm_oip)

    # Farmacia other establishment
    @other_establishment = create(:establishment_2, sanitary_zone: @iv_zone, establishment_type: @establishment_type)
    @farmacia_other_establishment = create(:sector_4, establishment: @other_establishment)
    @farmacia_hja = create(:user_3, sector: @farmacia_other_establishment)
    @pm_oe_applicant = create(:permission_module, name: 'Ordenes Externas Solicitud')
    @read_external_order_applicant = create(:permission, name: 'read_external_order_applicant',
                                                         permission_module: @pm_oe_applicant)
    @create_external_order_applicant = create(:permission, name: 'create_external_order_applicant',
                                                           permission_module: @pm_oe_applicant)
    @update_external_order_applicant = create(:permission, name: 'update_external_order_applicant',
                                                           permission_module: @pm_oe_applicant)
    @destroy_external_order_applicant = create(:permission, name: 'destroy_external_order_applicant',
                                                            permission_module: @pm_oe_applicant)
    @send_external_order_applicant = create(:permission, name: 'send_external_order_applicant',
                                                         permission_module: @pm_oe_applicant)
    @receive_external_order_applicant = create(:permission, name: 'receive_external_order_applicant',
                                                            permission_module: @pm_oe_applicant)
    @return_external_order_applicant = create(:permission, name: 'return_external_order_applicant',
                                                           permission_module: @pm_oe_applicant)

    # Deposito other establishment
    @pm_oe_provider = create(:permission_module, name: 'Ordenes Externas Proveedor')
    @read_external_order_provider = create(:permission, name: 'read_external_order_provider',
                                                        permission_module: @pm_oe_provider)
    @create_external_order_provider = create(:permission, name: 'create_external_order_provider',
                                                          permission_module: @pm_oe_provider)
    @update_external_order_provider = create(:permission, name: 'update_external_order_provider',
                                                          permission_module: @pm_oe_provider)
    @destroy_external_order_provider = create(:permission, name: 'destroy_external_order_provider',
                                                           permission_module: @pm_oe_provider)
    @send_external_order_provider = create(:permission, name: 'send_external_order_provider',
                                                        permission_module: @pm_oe_provider)
    @nullify_external_order_provider = create(:permission, name: 'nullify_external_order_provider',
                                                           permission_module: @pm_oe_provider)
    @return_external_order_provider = create(:permission, name: 'return_external_order_provider',
                                                          permission_module: @pm_oe_provider)
    @accept_external_order_provider = create(:permission, name: 'accept_external_order_provider',
                                                          permission_module: @pm_oe_provider)

  
  end
end
