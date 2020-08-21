class InternalOrderProduct < ApplicationRecord

  enum status: { sin_entregar: 0, entregado: 1, sin_stock: 2 }

  # Relaciones
  belongs_to :internal_order
  belongs_to :product

  has_many :int_ord_prod_lot_stocks

  # Validaciones
  validates :request_quantity, :numericality => { :only_integer => true, :greater_than_or_equal_to => 0 }
  validates :delivery_quantity, :numericality => { :only_integer => true, :greater_than_or_equal_to => 0 }, if: :is_proveedor_auditoria?
  
  validates_associated :product
  
  accepts_nested_attributes_for :product,
    :allow_destroy => true

  accepts_nested_attributes_for :int_ord_prod_lot_stocks,
    :allow_destroy => true

  # Delegaciones
  delegate :unity, to: :product
  delegate :name, to: :product, prefix: :product
  
  # Scopes
  scope :agency_referrals, -> (id, city_town) { includes(client: :address).where(agency_id: id, 'client.address.city_town' => city_town) }
  scope :to_sector, lambda { |a_sector| joins(:sector_supply_lot).where(sector_supply_lots: { sector: a_sector }) }

  scope :dispensed_since, lambda { |a_date| where('quantity_ord_supply_lots.dispensed_at >= ?', a_date) }
  scope :dispensed_to, lambda { |a_date| where('quantity_ord_supply_lots.dispensed_at <= ?', a_date ) }

  # Métodos públicos
  def increment_lot_to(a_sector)
    if self.delivered_quantity > 0
      if self.sector_supply_lot.present?
        @sector_supply_lot = SectorSupplyLot.where(
          sector_id: a_sector.id,
          supply_lot_id: self.sector_supply_lot.supply_lot_id
        ).first_or_create
        @sector_supply_lot.increment(self.delivered_quantity)
        self.dispensed_at = DateTime.now
        self.entregado!
      else
        self.sin_stock!
      end
    end
  end

  def increment_new_lot_to(a_sector)
    if self.lot_code.present? && self.laboratory_id.present?
      @supply_lot = SupplyLot.where(
        supply_id: self.supply_id,
        lot_code: self.lot_code,
        laboratory_id: self.laboratory_id,
      ).first_or_initialize
      @supply_lot.expiry_date = self.expiry_date
      @supply_lot.date_received = DateTime.now
      @supply_lot.save!
      @sector_supply_lot = SectorSupplyLot.where(
        sector_id: a_sector.id,
        supply_lot_id: @supply_lot.id
      ).first_or_create
      @sector_supply_lot.increment(self.delivered_quantity)
      self.dispensed_at = DateTime.now
      self.entregado!
    else
      raise ArgumentError, 'El insumo '+self.supply_name+' no tiene lote asignado.'
    end
  end

  # Decrement delivered quantity to sector supply lot and turn status "Entregado"
  def decrement
    if self.sector_supply_lot.present?
      self.sector_supply_lot.decrement(self.delivered_quantity)
    end
    self.dispensed_at = DateTime.now
    self.entregado!
  end

  # Dispense supply of cronic prescription
  def decrement_to_cronic(cronic_dispensation)
    if self.sector_supply_lot.present?
      if self.sector_supply_lot.decrement(self.delivered_quantity)
        new_qosl = self.dup  # Clone the actual QOSL
        new_qosl.save! # Save the clone
        self.cronic_dispensation = cronic_dispensation # Assign the current dispensation
        self.dispensed_at = DateTime.now
        self.entregado!
      end
    else
      cronic_dispensation.destroy
      raise ArgumentError, 'No hay lote asignado para '+self.supply_name
    end
  end

  # Increment delivered quantity to sector supply lot and turn status "Sin entregar"
  def increment
    if self.sector_supply_lot.present?
      self.sector_supply_lot.increment(self.delivered_quantity)
    end
    self.sin_entregar!
  end

  # Getter sector supply lot code
  def sector_supply_lot_lot_code
    if self.sector_supply_lot.present?  
      self.sector_supply_lot.lot_code
    elsif self.lot_code.present?
      self.lot_code
    else
      'n/a'
    end
  end

  # Getter sector supply lot expiry date
  def sector_supply_lot_expiry_date
    if self.sector_supply_lot.present?
      self.sector_supply_lot.format_expiry_date
    elsif self.expiry_date.present?
      self.expiry_date.strftime('%m/%y')
    elsif self.lot_code.present?
      'No vence'
    else 
      'n/a'  
    end
  end

  # Getter sector supply lot laboratory name
  def sector_supply_lot_laboratory_name
    if self.sector_supply_lot.present?
      self.sector_supply_lot.laboratory
    elsif self.laboratory.present?
      self.laboratory.name
    else
      'n/a'
    end
  end

  # Return true if the order was delivered by the sector
  def delivered_with_sector?(a_sector)
    self.quantifiable.delivered_with_sector?(a_sector)
  end

  # Return true if the Ordering Supply is a "Recibo"
  def quantifiable_is_recibo?
    if quantifiable.class.name == "ExternalOrder"
      return quantifiable.recibo?
    end 
  end
  
  # Return all orders related to a sector and a supply code
  def self.orders_to(a_sector, a_code)
    QuantityOrdSupplyLot.where.not(quantifiable: nil)
      .entregado
      .where(supply_id: a_code)
      .includes(:quantifiable)
      .select { |qosl| qosl.delivered_with_sector?(a_sector) }
  end

  # Return true if the Ordering Supply is a "Recibo"
  def is_proveedor_auditoria?
    return self.internal_order.proveedor_auditoria?
    # if quantifiable.class.name == "ExternalOrder"
    #   return quantifiable.recibo?
    # end 
  end
end

