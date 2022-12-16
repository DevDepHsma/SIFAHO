def external_orders_provider_populate
  10.times do
    charset = Array('A'..'Z') + Array('a'..'z')
    remit_code = Array.new(20) { charset.sample }.join
    order=ExternalOrder.new(provider_sector_id: @farm_provider.active_sector.id, applicant_sector_id: @depo_applicant.active_sector.id,
                          order_type: 'provision', remit_code: remit_code, status: 'proveedor_auditoria', requested_date: DateTime.now)
                          order.save(validate:false)
  end
  10.times do
    charset = Array('A'..'Z') + Array('a'..'z')
    remit_code = Array.new(20) { charset.sample }.join
    order=ExternalOrder.new(provider_sector_id: @farm_provider.active_sector.id, applicant_sector_id: @depo_applicant.active_sector.id,
                          order_type: 'solicitud', remit_code: remit_code, status: 'proveedor_auditoria', requested_date: DateTime.now)
                          order.save(validate:false)
  end

  10.times do
    charset = Array('A'..'Z') + Array('a'..'z')
    remit_code = Array.new(20) { charset.sample }.join
    order=ExternalOrder.new(provider_sector_id: @farm_provider.active_sector.id, applicant_sector_id: @depo_applicant.active_sector.id,
                          order_type: 'solicitud', remit_code: remit_code, status: 'provision_en_camino', requested_date: DateTime.now)
                          order.save(validate:false)
  end
  10.times do
    charset = Array('A'..'Z') + Array('a'..'z')
    remit_code = Array.new(20) { charset.sample }.join
    order=ExternalOrder.new(provider_sector_id: @farm_applicant.active_sector.id, applicant_sector_id: @depo_applicant.active_sector.id,
                          order_type: 'provision', remit_code: remit_code, status: 'solicitud_enviada', requested_date: DateTime.now)
                          order.save(validate:false)
  end
end