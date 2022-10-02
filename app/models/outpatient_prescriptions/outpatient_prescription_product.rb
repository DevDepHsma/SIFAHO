class OutpatientPrescriptionProduct < ApplicationRecord
  # Relationships
  belongs_to :outpatient_prescription, inverse_of: 'outpatient_prescription_products'
  has_one :patient, through: :outpatient_prescription
  belongs_to :product
  has_many :order_prod_lot_stocks, dependent: :destroy, class_name: 'OutPresProdLotStock',
                                   foreign_key: 'outpatient_prescription_product_id', source: :out_pres_prod_lot_stocks, inverse_of: 'outpatient_prescription_product'
  has_many :lot_stocks, through: :order_prod_lot_stocks

  # Validations
  validates :request_quantity, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :delivery_quantity, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 },
                                if: :is_pending?
  validate :out_of_stock, if: :is_provision_dispensed?
  validate :lot_stock_sum_quantity, if: :is_provision_dispensed?
  validates_presence_of :product_id
  validates :order_prod_lot_stocks, presence: { message: 'Debe seleccionar almenos 1 lote' },
                                    if: :is_dispensed_and_quantity_greater_than_0?
  validates_associated :order_prod_lot_stocks, if: :is_provision_dispensed?
  validate :uniqueness_product_in_the_order
  validate :order_prod_lot_stocks_any_without_stock

  # Nested attributes
  accepts_nested_attributes_for :product,
                                allow_destroy: true
  accepts_nested_attributes_for :order_prod_lot_stocks,
                                allow_destroy: true

  # Delegations
  delegate :unity, to: :product
  delegate :name, to: :product, prefix: :product
  delegate :code, to: :product, prefix: :product

  # Scopes
  scope :agency_referrals, lambda { |id, city_town|
                             includes(client: :address).where(agency_id: id, 'client.address.city_town' => city_town)
                           }

  scope :get_delivery_products_by_patient, lambda { |filter_params|
    select('SUM("delivery_quantity") as product_quantity',
           :product_id,
           'patients.id as patient_id',
           'CONCAT(patients.last_name, \' \', patients.first_name) as patient_full_name',
           'patients.dni as patient_dni',
           'patients.birthdate as patient_birthdate')
      .joins(:patient)
      .where(outpatient_prescription_id: OutpatientPrescription.where(provider_sector_id: filter_params[:sector_id],
                                                                      status: 'dispensada',
                                                                      patient_id: filter_params[:patient_ids]))
      .where(product_id: filter_params[:product_ids])
      .group('patients.id', :product_id)
      .order('patient_full_name ASC')
  }

  # new version
  def is_pending?
    outpatient_prescription.pendiente?
  end

  def is_provision_dispensed?
    outpatient_prescription.dispensada?
  end

  def is_dispensed_and_quantity_greater_than_0?
    is_provision_dispensed? && (delivery_quantity.present? && delivery_quantity > 0)
  end

  # Decrementamos la cantidad de cada lot stock (proveedor)
  def decrement_stock
    order_prod_lot_stocks.each do |oppls|
      oppls.lot_stock.decrement(oppls.quantity, outpatient_prescription)
    end
  end

  # Incrementamos la cantidad de cada lot stock (orden)
  def increment_stock
    order_prod_lot_stocks.each do |oppls|
      oppls.lot_stock.increment(oppls.quantity, outpatient_prescription)
      # oppls.lot_stock.stock.create_stock_movement(self.outpatient_prescription, oppls.lot_stock, oppls.quantity, true)
    end
  end

  # custom validations
  # Validacion: la cantidad no debe ser mayor o menor a la cantidad a entregar
  def lot_stock_sum_quantity
    total_quantity = 0
    order_prod_lot_stocks.each do |oppls|
      total_quantity += oppls.quantity unless oppls.marked_for_destruction?
    end
    if delivery_quantity.present? && delivery_quantity < total_quantity
      errors.add(:quantity_lot_stock_sum,
                 "El total de productos seleccionados no debe superar #{delivery_quantity}")
    end

    if delivery_quantity.present? && delivery_quantity > total_quantity
      errors.add(:quantity_lot_stock_sum,
                 "El total de productos seleccionados debe ser igual a #{delivery_quantity}")
    end
  end

  # Validacion: evitar duplicidad de productos en una misma orden
  def uniqueness_product_in_the_order
    (outpatient_prescription.outpatient_prescription_products.uniq - [self]).each do |opp|
      if opp.product_id == product_id
        errors.add(:uniqueness_product_in_the_order, 'Este producto ya se encuentra en la orden')
      end
    end
  end

  # Validacion: algun lote que se este seleccionando una cantidad superior a la persistente
  def order_prod_lot_stocks_any_without_stock
    any_insufficient_lot_stock = order_prod_lot_stocks.any? do |opls|
      opls.errors[:quantity].any?
    end

    if any_insufficient_lot_stock
      errors.add(:order_prod_lot_stocks_any_without_stock, 'Revisar las cantidades seleccionadas')
    end
  end

  # Validacion: evitar la dispensacion de una orden si no tiene stock para dispensar
  def out_of_stock
    total_stock = outpatient_prescription.provider_sector.stocks.where(product_id: product_id).sum(:quantity)
    if delivery_quantity.present? && total_stock < delivery_quantity
      errors.add(:out_of_stock, 'Este producto no tiene el stock necesario para entregar')
    end
  end

  def get_order
    outpatient_prescription
  end
end
