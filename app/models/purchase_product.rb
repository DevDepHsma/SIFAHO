class PurchaseProduct < ApplicationRecord
  # Relaciones
  belongs_to :purchase, inverse_of: 'purchase_products'
  belongs_to :product

  has_many :order_prod_lot_stocks, -> { order 'position DESC' }, dependent: :destroy, class_name: "PurchaseProdLotStock", foreign_key: "purchase_product_id", source: :purchase_prod_lot_stocks, inverse_of: 'purchase_product'
  has_many :lot_stocks, :through => :order_prod_lot_stocks

  validates_associated :order_prod_lot_stocks
  validates_presence_of :product_id
  validate :atleast_one_lot_selected
  # Atributos anidados
  accepts_nested_attributes_for :order_prod_lot_stocks,
    :allow_destroy => true

  delegate :code, to: :product, prefix: true
  delegate :name, to: :product, prefix: true

  # Validacion: evitar el envio de una orden si no tiene stock para enviar
  def atleast_one_lot_selected
    if self.order_prod_lot_stocks.size == 0
      errors.add(:atleast_one_lot_selected, "Debe seleccionar almenos 1 lote")
    end
  end

  # Incrementamos la cantidad de lot stock 
  def increment_lot_stock_to(a_sector)

    self.order_prod_lot_stocks.each do |opls|
      # Se busca o crea Lote
      @lot = Lot.where(
        product_id: self.product_id,
        code: opls.lot_code,
        laboratory_id: opls.laboratory_id,
        expiry_date: opls.expiry_date
      ).first_or_create

      # Se busca o crea Stock
      @stock = Stock.where(
        sector_id: a_sector.id,
        product_id: self.product_id
      ).first_or_create

      # Se busca o crea LotStock
      @lot_stock = LotStock.where(
        lot_id: @lot.id,
        stock_id: @stock.id,
      ).first_or_create

      # Se incrementa el LotStock
      @lot_stock.increment((opls.quantity * opls.presentation))
      opls.lot_stock_id = @lot_stock.id
      opls.save!
      @stock.create_stock_movement(a_sector, self.purchase, @lot_stock, opls.quantity * opls.presentation, true)
    end
  end

  def get_quantity
    return self.order_prod_lot_stocks.sum('presentation * quantity')
  end

  # Decrementamos la cantidad de cada lot stock (proveedor)
  def decrement_stock
    self.order_prod_lot_stocks.each do |opls|
      opls.lot_stock.decrement(opls.presentation * opls.quantity)
      opls.lot_stock.stock.create_stock_movement(self.purchase.applicant_sector, self.purchase, opls.lot_stock, opls.quantity * opls.presentation, false)
    end
  end

end
