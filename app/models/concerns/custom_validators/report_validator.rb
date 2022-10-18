class CustomValidators::ReportValidator < ActiveModel::Validator
  def validate(record)
    products = Product.select(:id, :name, :code).by_stock(record.sector_id).where(id: record.products_ids.split('_'))
    record.errors.add(:products_ids, 'No debe superar el máximo de 11 productos') if products.length > 11
    record.errors.add(:products_ids, 'Debe seleccionar almenos 1 producto') if products.length.zero?
  end
end
