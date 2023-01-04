# == Schema Information

# Table name: chronic_dispensations

# chronic_prescription_id    :bigint   not null
# observation                :text     optional
# status                     :integer  not null, default 0, options {pendiente: 0, dispensada: 1}
# provider_sector_id         :bigint   not null
#

class ChronicDispensation < ApplicationRecord
  belongs_to :chronic_prescription
  has_many :dispensation_types, dependent: :destroy, class_name: 'DispensationType'
  has_many :chronic_prescription_products, through: :dispensation_types
  has_many :order_prod_lot_stocks, through: :chronic_prescription_products
  has_many :lot_stocks, :through => :order_prod_lot_stocks
  belongs_to :provider_sector, class_name: 'Sector'

  enum status: { pendiente: 0, dispensada: 1 }

  validate :presence_of_products_into_dispensation
  validates_associated :dispensation_types
  accepts_nested_attributes_for :dispensation_types, reject_if: :dispensation_type_rejectable?

  after_create :decrement_stock, :dispense_prescription, :set_on_chronic_prescription_product
  
  def dispensation_type_rejectable?(att)
    !att["chronic_prescription_products_attributes"].present?
  end

  def decrement_stock
    self.dispensation_types.each do |dt|
      dt.chronic_prescription_products.each do |cpp|
        cpp.decrement_stock
      end
    end
  end

  def presence_of_products_into_dispensation
    @products = 0
    self.dispensation_types.each do |dt|
      @products += dt.chronic_prescription_products.size
    end
    errors.add(:presence_of_products_into_dispensation, "Debe dispensar almenos 1 insumo") unless @products > 0
  end

  # Incrementa la cantidad total dispensada:
  # Sumar 1 dosis o Sumar la cantidad segun corresponda [dispensation_type]
  def dispense_prescription
    self.chronic_prescription.original_chronic_prescription_products.each do |original_product|
      dispensation_type = self.dispensation_types.where(original_chronic_prescription_product_id: original_product.id).first

      original_product.deliver(dispensation_type.quantity) if dispensation_type.present?
    end
    self.chronic_prescription.update_status
    self.chronic_prescription.save
  end

  def set_on_chronic_prescription_product
    chronic_prescription_products.each do |cpp|
      cpp.chronic_dispensation_id = self.id
      cpp.save
    end
  end

  def return_dispensation
    # primero actualizamos los totales de la dosis de cada producto original recetado
    self.chronic_prescription.original_chronic_prescription_products.each do |original_product|
      self.dispensation_types.each do |dp|
        # Retornamos la cantidad
        is_original_present = dp.chronic_prescription_products.where(original_chronic_prescription_product_id: original_product.id).first

        original_product.return(dp.quantity) if is_original_present.present?
      end
      original_product.save!
    end
    
    self.dispensation_types.each do |dt| 
      dt.chronic_prescription_products.each do | cpp |
        cpp.increment_stock
      end
    end
  end

end