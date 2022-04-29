RSpec.configure do |config|

  config.before(:all) do
    @establishment = create(:establishment_1)
    @deposito = create(:sector_4, establishment: @establishment)
    @farmacia = create(:sector_1, establishment: @establishment)
    @applicant_user = create(:user_1, sector: @farmacia)
    @provider_user = create(:user_2, sector: @deposito)

    @pm_ois = create(:permission_module, name: 'Ordenes Internas Solicitud')
    @read_internal_order_applicant = create(:permission, name: 'read_internal_order_applicant', permission_module: @pm_ois)
    @create_internal_order_applicant = create(:permission, name: 'create_internal_order_applicant', permission_module: @pm_ois)
    @update_internal_order_applicant = create(:permission, name: 'update_internal_order_applicant', permission_module: @pm_ois)
    @destroy_internal_order_applicant = create(:permission, name: 'destroy_internal_order_applicant', permission_module: @pm_ois)
    @send_internal_order_applicant = create(:permission, name: 'send_internal_order_applicant', permission_module: @pm_ois)
    @receive_internal_order_applicant = create(:permission, name: 'receive_internal_order_applicant', permission_module: @pm_ois)
    @return_internal_order_applicant = create(:permission, name: 'return_internal_order_applicant', permission_module: @pm_ois)

    @pm_oip = create(:permission_module, name: 'Ordenes Internas Proveedor')
    @read_internal_order_provider = create(:permission, name: 'read_internal_order_provider', permission_module: @pm_oip)
    @create_internal_order_provider = create(:permission, name: 'create_internal_order_provider', permission_module: @pm_oip)
    @update_internal_order_provider = create(:permission, name: 'update_internal_order_provider', permission_module: @pm_oip)
    @destroy_internal_order_provider = create(:permission, name: 'destroy_internal_order_provider', permission_module: @pm_oip)
    @send_internal_order_provider = create(:permission, name: 'send_internal_order_provider', permission_module: @pm_oip)
    @nullify_internal_order_provider = create(:permission, name: 'nullify_internal_order_provider', permission_module: @pm_oip)
    @return_internal_order_provider = create(:permission, name: 'return_internal_order_provider', permission_module: @pm_oip)

    @products = get_products
    @unity = create(:unidad_unity)
    @area = create(:medication_area)
    @lab = create(:abbott_laboratory)
    @provenance = create(:province_lot_provenance)
    @products.each_with_index do |product, index|
      prod = create(:product, name: product[0], code: product[1], area: @area, unity: @unity)
      lot = create(:lot, laboratory: @lab, product: prod, code: "BB-#{index}", expiry_date:  Date.today + 15.month, provenance: @provenance)
      stock = create(:stock, product: prod, sector: @deposito)
      LotStock.create(quantity: rand(1500..5000), lot: lot, stock: stock)
    end
  end
end