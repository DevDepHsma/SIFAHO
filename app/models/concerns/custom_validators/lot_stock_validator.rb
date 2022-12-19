class CustomValidators::LotStockValidator < ActiveModel::Validator
  def validate(record)
    puts options
    puts "<======".colorize(background: :red)
    # if a_quantity.negative?
    #   raise ArgumentError, 'La cantidad a decrementar debe ser mayor a 0.'
    # elsif a_quantity > self.quantity
    # raise ArgumentError, "La cantidad en stock es insuficiente del lote #{lot_code} producto #{product_name}."
    # else
    raise ArgumentError, "Debe seleccionar una cantidad"
  end
end
