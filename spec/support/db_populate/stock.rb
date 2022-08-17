def stock_populate(config, sector)
  config.before(:all, type: :feature) do
    @products = Product.all
    @products.each do |prod|
      stock = create(:stock, product: prod, sector: sector)
      LotStock.create(quantity: rand(5000..10_000), lot: prod.lot, stock: stock)
    end
  end
end
