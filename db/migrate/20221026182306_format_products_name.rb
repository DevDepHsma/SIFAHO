class FormatProductsName < ActiveRecord::Migration[5.2]
  def change
    Product.all.each do |product|
      product.name = product.name
      product.save!
    end
  end
end
