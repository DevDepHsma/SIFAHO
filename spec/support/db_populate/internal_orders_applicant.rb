def internal_orders_applicant_populate

  10.times do
    charset = Array('A'..'Z') + Array('a'..'z')
    remit_code = Array.new(20) { charset.sample }.join
    InternalOrder.create!(provider_sector_id: @depo_applicant.sector_id, applicant_sector_id: @farm_applicant.sector_id,
                          order_type: 'solicitud', remit_code: remit_code, status: 'solicitud_auditoria', observation: 'esta es una gran observacion', requested_date: DateTime.now)
  end
  
  10.times do
    charset = Array('A'..'Z') + Array('a'..'z')
    remit_code = Array.new(20) { charset.sample }.join
    InternalOrder.create!(provider_sector_id: @depo_applicant.sector_id + 1, applicant_sector_id: @farm_applicant.sector_id,
                          order_type: 'provision', remit_code: remit_code, status: 'provision_en_camino', observation: 'esta es una gran observacion', requested_date: DateTime.now)
  end
  10.times do
    charset = Array('A'..'Z') + Array('a'..'z')
    remit_code = Array.new(20) { charset.sample }.join
    InternalOrder.create!(provider_sector_id: @depo_applicant.sector_id + 1, applicant_sector_id: @farm_applicant.sector_id,
                          order_type: 'provision', remit_code: remit_code, status: 'solicitud_enviada', observation: 'esta es una gran observacion', requested_date: DateTime.now)
  end
end
