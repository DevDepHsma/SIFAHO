def stocks_populate
  @products = Product.all
  @products.each do |prod|
    [@farm_est_1, @depo_est_1, @farm_est_2, @depo_est_2].each do |sector|
      stock = create(:stock, product: prod, sector: sector)
      LotStock.create(quantity: rand(50_000..100_000), lot: prod.lots.first, stock: stock)
    end
  end
end
