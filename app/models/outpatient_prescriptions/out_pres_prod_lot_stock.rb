# == Schema Information

# Table name: out_pres_prod_lot_stocks

# outpatient_prescription_product_id     :bigint      not null
# lot_stock_id                           :bigint      not null
# quantity                               :integer     not null
# created_at                             :datetime    auto
# updated_at                             :datetime    auto

class OutPresProdLotStock < ApplicationRecord
  # Relationships
  belongs_to :outpatient_prescription_product, inverse_of: 'order_prod_lot_stocks'
  belongs_to :lot_stock
  has_one :order, through: :outpatient_prescription_product, source: :outpatient_prescription

  # Validations
  validates :quantity,
            numericality: { only_integer: true, less_than_or_equal_to: :lot_stock_quantity,
                            message: 'La cantidad seleccionada debe ser menor o igual a %{count}' }
  validates :quantity,
            numericality: { only_integer: true, greater_than: 0,
                            message: 'La cantidad seleccionada debe ser mayor a %{count}' }
  validates_presence_of :lot_stock_id

  # Nested attributes
  accepts_nested_attributes_for :lot_stock,
                                allow_destroy: true

  delegate :code, to: :lot_stocks, prefix: :product
  delegate :destiny_name, :origin_name, :status, to: :order

  def lot_stock_quantity
    lot_stock.quantity
  end

  def order_human_name
    order.class.model_name.human
  end

  def is_destiny?(_a_sector)
    false
  end
end
