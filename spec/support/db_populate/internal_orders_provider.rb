def internal_orders_provider_populate
  with_stock=Stock.where('quantity>?',0)
  products_with_stocks=Product.where(id:with_stock.pluck(:product_id).uniq)
  5.times do
    charset = Array('A'..'Z') + Array('a'..'z')
    remit_code = Array.new(20) { charset.sample }.join
    order = InternalOrder.new(provider_sector_id: @farm_applicant.active_sector.id, applicant_sector_id: @depo_applicant.active_sector.id,
                              order_type: 'provision', remit_code: remit_code, status: 'proveedor_auditoria', observation: 'esta es una gran observacion', requested_date: DateTime.now)
    order.save(validate: false)
  end
  10.times do
    charset = Array('A'..'Z') + Array('a'..'z')
    remit_code = Array.new(20) { charset.sample }.join
    order = InternalOrder.new(provider_sector_id: @farm_applicant.active_sector.id, applicant_sector_id: @depo_applicant.active_sector.id,
                              order_type: 'solicitud', remit_code: remit_code, status: 'proveedor_auditoria', observation: 'esta es una gran observacion', requested_date: DateTime.now)
    order.save(validate: false)
  end
  3.times do
    charset = Array('A'..'Z') + Array('a'..'z')
    remit_code = Array.new(20) { charset.sample }.join
    order = InternalOrder.new(provider_sector_id: @farm_applicant.active_sector.id, applicant_sector_id: @depo_applicant.active_sector.id,
                              order_type: 'solicitud', remit_code: remit_code, status: 'provision_en_camino', observation: 'esta es una gran observacion', requested_date: DateTime.now)
    order.save(validate: false)
  end
  establishment=@depo_applicant.active_sector.establishment
  sectors=Sector.where(establishment_id:establishment.id).pluck(:id)
  i=0
  12.times do
    charset = Array('A'..'Z') + Array('a'..'z')
    remit_code = Array.new(20) { charset.sample }.join
    order = InternalOrder.new(provider_sector_id: @farm_applicant.active_sector.id, applicant_sector_id: sectors[i],
                              order_type: 'solicitud', remit_code: remit_code, status: 'provision_en_camino', observation: 'esta es una gran observacion', requested_date: DateTime.now)
    order.save(validate: false)
    order_products = InternalOrderProduct.new(order_id: order.id, product_id:products_with_stocks.sample.id, request_quantity: 5, delivery_quantity: 1,
                                              provider_observation: nil,
                                              applicant_observation: nil,
                                              created_at: 'Wed, 20 May 2020 09:36:59 -03 -03:00',
                                              updated_at: 'Tue, 21 Sep 2021 12:14:50 -03 -03:00',
                                              added_by_sector_id:  @farm_applicant.active_sector.id)
    order_products.save(validate: false)
    i=i+1
  end
  
  10.times do
    charset = Array('A'..'Z') + Array('a'..'z')
    remit_code = Array.new(20) { charset.sample }.join
    order = InternalOrder.new(provider_sector_id: @farm_applicant.active_sector.id, applicant_sector_id: sectors.sample,
                              order_type: 'solicitud', remit_code: remit_code, status: 'solicitud_enviada', observation: 'esta es una gran observacion', requested_date: DateTime.now)
    order.save(validate: false)
  end
end
