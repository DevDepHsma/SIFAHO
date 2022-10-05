class ChronicPrescriptionProduct < ApplicationRecord
  # Relationships
  belongs_to :original_chronic_prescription_product, inverse_of: 'chronic_prescription_products', optional: true
  has_one :chronic_prescription, through: :original_chronic_prescription_product
  has_one :patient, through: :chronic_prescription
  belongs_to :product
  belongs_to :dispensation_type

  has_many :order_prod_lot_stocks, dependent: :destroy, class_name: 'ChronPresProdLotStock',
                                   foreign_key: 'chronic_prescription_product_id', source: :chron_pres_prod_lot_stocks, inverse_of: 'chronic_prescription_product'
  has_many :lot_stocks, through: :order_prod_lot_stocks

  # Validations
  validates :delivery_quantity, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validate :out_of_stock, if: :is_dispensation?
  validate :lot_stock_sum_quantity, if: :is_dispensation?
  validates_presence_of :product_id
  validates :order_prod_lot_stocks, presence: { message: 'Debe seleccionar almenos 1 lote' }, if: :is_dispensation?
  validates_associated :order_prod_lot_stocks, if: :is_dispensation?
  validate :uniqueness_product_in_the_order
  validate :order_prod_lot_stocks_any_without_stock, if: :is_dispensation?
  validates_presence_of :original_chronic_prescription_product, if: :is_not_dispensation?

  accepts_nested_attributes_for :product,
                                allow_destroy: true
  accepts_nested_attributes_for :order_prod_lot_stocks,
                                allow_destroy: true

  # Delegations
  delegate  :name, :code, to: :product, prefix: :product

  scope :get_delivery_products_by_patient, lambda { |filter_params|
    sub_query_prescriptions = ChronicDispensation.where(provider_sector_id: filter_params[:sector_id],
                                                        status: [:dispensada])

    unless filter_params[:all_patients].present?
      sub_query_prescriptions = sub_query_prescriptions.where(chronic_prescription_id: ChronicPrescription.where(patient_id: filter_params[:patient_ids]))
    end

    if filter_params[:from_date].present?
      sub_query_prescriptions = sub_query_prescriptions.where('created_at >= ?', filter_params[:from_date])
    end

    if filter_params[:to_date].present?
      sub_query_prescriptions = sub_query_prescriptions.where('created_at <= ?', filter_params[:to_date])
    end

    query = select('SUM("delivery_quantity") as product_quantity',
                   'products.id as product_id',
                   'products.code as product_code',
                   'products.name as product_name',
                   'patients.id as patient_id',
                   'CONCAT(patients.last_name, \' \', patients.first_name) as patient_full_name',
                   'patients.dni as patient_dni',
                   'patients.birthdate as patient_birthdate')
            .joins(:patient, :product)
            .where(chronic_dispensation_id: sub_query_prescriptions)
    query = query.where(product_id: filter_params[:product_ids]) unless filter_params[:all_products].present?
    query = query.group('patients.id', 'products.id')
                 .order('patient_full_name ASC')
    return query
  }

  scope :get_delivery_products_by_patient, lambda { |filter_params|
    sub_query_prescriptions = ChronicDispensation.where(provider_sector_id: filter_params[:sector_id],
                                                        status: [:dispensada])

    unless filter_params[:all_patients].present?
      sub_query_prescriptions = sub_query_prescriptions.where(chronic_prescription_id: ChronicPrescription.where(patient_id: filter_params[:patient_ids]))
    end

    if filter_params[:from_date].present?
      sub_query_prescriptions = sub_query_prescriptions.where('created_at >= ?', filter_params[:from_date])
    end

    if filter_params[:to_date].present?
      sub_query_prescriptions = sub_query_prescriptions.where('created_at <= ?', filter_params[:to_date])
    end

    query = select('SUM("delivery_quantity") as product_quantity',
                   'products.id as product_id',
                   'products.code as product_code',
                   'products.name as product_name',
                   'patients.id as patient_id',
                   'CONCAT(patients.last_name, \' \', patients.first_name) as patient_full_name',
                   'patients.dni as patient_dni',
                   'patients.birthdate as patient_birthdate')
            .joins(:patient, :product)
            .where(chronic_dispensation_id: sub_query_prescriptions)
    query = query.where(product_id: filter_params[:product_ids]) unless filter_params[:all_products].present?
    query = query.group('patients.id', 'products.id')
                 .order('patient_full_name ASC')
    return query
  }

  # custom validations
  def is_dispensation?
    dispensation_type.chronic_dispensation.present? && dispensation_type.chronic_dispensation.pendiente?
  end

  def is_not_dispensation?
    !dispensation_type.chronic_dispensation.present?
  end

  # Validacion: la cantidad no debe ser mayor o menor a la cantidad a entregar
  def lot_stock_sum_quantity
    total_quantity = 0
    order_prod_lot_stocks.each do |iopls|
      total_quantity += iopls.quantity unless iopls.marked_for_destruction?
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

  # Validacion: evitar el envio de una orden si no tiene stock para enviar
  def out_of_stock
    total_stock = dispensation_type.chronic_dispensation.provider_sector.stocks.where(product_id: product_id).sum(:quantity)
    if delivery_quantity.present? && total_stock < delivery_quantity
      errors.add(:out_of_stock, 'Este producto no tiene el stock necesario para entregar')
    end
  end

  # Validacion: evitar duplicidad de productos en una misma orden
  def uniqueness_product_in_the_order
    (dispensation_type.chronic_prescription_products.uniq - [self]).each do |iop|
      if iop.product_id == product_id
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

  # Decrementamos la cantidad de cada lot stock (proveedor)
  def decrement_stock
    order_prod_lot_stocks.each do |cpp|
      cpp.lot_stock.decrement(cpp.quantity, dispensation_type.chronic_dispensation.chronic_prescription)
    end
  end

  # Incrementamos la cantidad de cada lot stock (proveedor). Utilizado para retornar
  def increment_stock
    order_prod_lot_stocks.each do |cpp|
      cpp.lot_stock.increment(cpp.quantity, dispensation_type.chronic_dispensation.chronic_prescription)
    end
  end
end
