class DispensationType < ApplicationRecord
  belongs_to :chronic_dispensation
  belongs_to :original_chronic_prescription_product
  has_many :chronic_prescription_products, inverse_of: 'dispensation_type'

  validates :quantity, :numericality => { :only_integer => true, :greater_than => 0 }
  validates :chronic_prescription_products, :presence => {:message => "Debe agregar almenos 1 insumo"}
  validates_associated :chronic_prescription_products

  accepts_nested_attributes_for :chronic_prescription_products,
  :allow_destroy => true

end
