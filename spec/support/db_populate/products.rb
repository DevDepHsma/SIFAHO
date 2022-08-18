def products_populate
  @unity = create(:unidad_unity)
  @area = create(:medication_area)
  @lab = create(:abbott_laboratory)
  @provenance = create(:province_lot_provenance)
  get_products.each_with_index do |product, index|
    prod = create(:product, name: product[0], code: product[1], area: @area, unity: @unity)
    create(:lot, laboratory: @lab, product: prod, code: "BB-#{index}", expiry_date: Date.today + 15.month,
                 provenance: @provenance)
    # stock = create(:stock, product: prod, sector: @deposito)
    # LotStock.create(quantity: rand(5000..10_000), lot: lot, stock: stock)
  end
end
