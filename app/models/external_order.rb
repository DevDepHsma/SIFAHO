class ExternalOrder < ApplicationRecord
  acts_as_paranoid
  include PgSearch

  # New enum
  enum order_type: { provision: 0, solicitud: 1 }
  enum status: { 
    solicitud_auditoria: 0, 
    solicitud_enviada: 1, 
    proveedor_auditoria: 2, 
    proveedor_aceptado: 3, 
    provision_en_camino: 4, 
    provision_entregada: 5,  
    anulado: 6 
  }

  # Old enum
  # enum order_type: { despacho: 0, solicitud_abastecimiento: 1, recibo: 2 }
  # enum status: {
  #   solicitud_auditoria: 0,
  #   solicitud_enviada: 1,
  #   proveedor_auditoria: 2,
  #   proveedor_aceptado: 3,
  #   provision_en_camino: 4, 
  #   provision_entregada: 5,
  #   recibo_auditoria: 6,
  #   recibo_realizado: 7,
  #   anulado: 8 }

  # Relaciones
  belongs_to :applicant_sector, class_name: 'Sector'
  belongs_to :provider_sector, class_name: 'Sector'
  has_many :external_order_products, dependent: :destroy, inverse_of: 'external_order'
  has_many :ext_ord_prod_lot_stocks, through: :external_order_products, inverse_of: 'external_order'
  has_many :lot_stocks, :through => :external_order_products
  has_many :lots, :through => :lot_stocks
  has_many :products, :through => :external_order_products  
  has_many :movements, class_name: "ExternalOrderMovement"
  has_many :comments, class_name: "ExternalOrderComment", foreign_key: "order_id", dependent: :destroy
  has_one :provider_establishment, :through => :provider_sector, source: 'establishment'
  has_one :applicant_establishment, :through => :applicant_sector, source: 'establishment'
  has_many :stock_movements, as: :order, dependent: :destroy, inverse_of: :order

  # Validaciones
  validates_presence_of :provider_sector_id, :applicant_sector_id, :requested_date, :remit_code
  validates :external_order_products, :presence => {:message => "Debe agregar almenos 1 insumo"}
  validates_associated :external_order_products
  validates_uniqueness_of :remit_code

  # Atributos anidados
  accepts_nested_attributes_for :external_order_products,
    :allow_destroy => true

  # Callbacks
  before_validation :record_remit_code, on: :create

  filterrific(
    default_filter_params: { sorted_by: 'created_at_desc' },
    available_filters: [
      :search_code,
      :search_applicant,
      :search_provider,
      :with_order_type,
      :with_status,
      :requested_date_since,
      :requested_date_to,
      :date_received_since,
      :date_received_to,
      :sorted_by
    ]
  )

  pg_search_scope :search_code,
    against: :remit_code,
    :using => {:tsearch => {:prefix => true} }, # Buscar coincidencia desde las primeras letras.
    :ignoring => :accents # Ignorar tildes.

  pg_search_scope :search_applicant,
    :associated_against => { :applicant_sector => :name, :applicant_establishment => :name },
    :using => {:tsearch => {:prefix => true} }, # Buscar coincidencia desde las primeras letras.
    :ignoring => :accents # Ignorar tildes.

  pg_search_scope :search_provider,
    :associated_against => { :provider_sector => :name, :provider_establishment => :name },
    :using => {:tsearch => {:prefix => true} }, # Buscar coincidencia desde las primeras letras.
    :ignoring => :accents # Ignorar tildes.

  scope :sorted_by, lambda { |sort_option|
    # extract the sort direction from the param value.
    direction = (sort_option =~ /desc$/) ? 'desc' : 'asc'
    case sort_option.to_s
    when /^created_at_/s
      # Ordenamiento por fecha de creación en la BD
      order("external_orders.created_at #{ direction }")
    when /^responsable_/
      # Ordenamiento por nombre de responsable
      order("LOWER(responsable.username) #{ direction }").joins("INNER JOIN users as responsable ON responsable.id = external_orders.responsable_id")
    when /^sector_/
      # Ordenamiento por nombre de sector
      order("sectors.name #{ direction }").joins(:sector)
    when /^estado_/
      # Ordenamiento por nombre de estado
      order("external_orders.status #{ direction }")
    when /^tipo_/
      # Ordenamiento por nombre de estado
      order("external_orders.order_type #{ direction }")
    when /^ins_/
      # Ordenamiento por nombre de insumo solicitado
      order("external_order_products.count #{ direction }")
    when /^solicitado_/
      # Ordenamiento por la fecha de recepción
      order("external_orders.requested_date #{ direction }") 
    when /^recibido_/
      # Ordenamiento por la fecha de recepción
      order("external_orders.date_received #{ direction }")
    else
      # Si no existe la opcion de ordenamiento se levanta la excepcion
      raise(ArgumentError, "Invalid sort option: #{ sort_option.inspect }")
    end
  }

  scope :date_received_since, lambda { |a_date|
    where('external_orders.date_received >= ?', a_date)
  }

  scope :date_received_to, lambda { |a_date|
    where('external_orders.date_received <= ?', a_date)
  }

  scope :requested_date_since, lambda { |a_date|
    where('external_orders.requested_date >= ?', a_date)
  }

  scope :requested_date_to, lambda { |a_date|
    where('external_orders.requested_date <= ?', a_date)
  }

  scope :with_status, lambda { |a_status|
    where('external_orders.status = ?', a_status)
  }

  scope :without_status, lambda { |a_status|
    where.not('external_orders.status = ?', a_status )
  }

  scope :without_order_type, lambda { |an_order_type|
    where.not('external_orders.order_type = ?', an_order_type )
  }

  scope :with_order_type, lambda { |a_order_type|
    where('external_orders.order_type = ?', a_order_type)
  }
  
  # Método para establecer las opciones del select input del filtro
  # Es llamado por el controlador como parte de `initialize_filterrific`.
  def self.options_for_sorted_by
    [
      ['Creación (desc)', 'created_at_desc'],
      ['Sector (a-z)', 'sector_asc'],
      ['Responsable (a-z)', 'responsable_asc'],
      ['Estado (a-z)', 'estado_asc'],
      ['Insumos solicitados (a-z)', 'insumos_solicitados_asc'],
      ['Fecha recibido (asc)', 'recibido_desc'],
    ]
  end

  def self.options_for_status
    [
      ['Todos', '', 'default'],
      ['Solicitud auditoria', 0, 'warning'],
      ['Solicitud enviada', 1, 'info'],
      ['Proveedor auditoria', 2, 'warning'],
      ['Proveedor aceptado', 3, 'primary'],
      ['Provisión en camino', 4, 'primary'],
      ['Provisión entregada', 5, 'success'],
      ['Recibo auditoria', 6, 'warning'],
      ['Recibo realizado', 7, 'success'],
      ['Anulado', 8, 'danger'],
    ]
  end

  public

  def self.provided_establishments_by(a_sector)
    @sector_ids = ExternalOrder.provider(a_sector).pluck(:applicant_sector_id).to_set
    return Establishment.joins(:sectors).where(sectors: { id: @sector_ids }).pluck(:id, :name).to_set
  end

  def self.applicant_establishment(a_establishment)
    @sector_ids = a_establishment.sectors.pluck(:id)
    applicant(@sector_ids)
  end

  def self.provider_establishment(a_establishment)
    @sector_ids = a_establishment.sectors.pluck(:id)
    provider(@sector_ids)
  end

  def self.applicant(a_sector)
    where(applicant_sector: a_sector)
  end

  def self.provider(a_sector)
    where(provider_sector: a_sector)
  end

  def is_provider?(a_user)
    return self.provider_sector == a_user.sector
  end

  def is_applicant?(a_user)
    return self.applicant_sector == a_user.sector
  end

  def sum_to?(a_sector)
    return self.applicant_sector == a_sector
  end

  def self.my_orders(a_sector)
    @my_delivery = self.provision.where(provider_sector: a_sector )
    @my_request = self.solicitud.where(applicant_sector: a_sector)
    
    return @my_delivery.or(@my_request)
  end
  
  def self.othere_orders(a_sector)
    @othere_delivery = self.provision.where(applicant_sector: a_sector)
    @othere_request = self.solicitud.where(provider_sector: a_sector)
    return @othere_delivery.or(@othere_request)
  end

  # def delivered_with_sector?(a_sector)
  #   if self.provision_en_camino? || self.provision_entregada?
  #     return self.applicant_sector == a_sector || self.provider_sector == a_sector
  #   elsif self.recibo_realizado?
  #     return self.applicant_sector == a_sector
  #   end
  # end

  # Cambia estado a "en camino" y descuenta la cantidad a los lotes de insumos
  def send_order_by(a_user)
    self.external_order_products.each do |iop|
      iop.decrement_stock
    end

    self.sent_date = DateTime.now
    self.save!(validate: false)

    self.create_notification(a_user, "envió")
  end

  # Cambia estado del pedido a "Aceptado" y se verifica que hayan lotes
  def receive_order_by(a_user)
    self.external_order_products.each do |eop|
      eop.increment_lot_stock_to(self.applicant_sector)
    end

    self.date_received = DateTime.now
    self.create_notification(a_user, "recibió")
    self.status = "provision_entregada"
    self.save!(validate: false)
  end

  # Nullify the order
  def nullify_by(a_user)
    self.anulado!
    self.create_notification(a_user, "Anuló")
  end

  # Método para retornar pedido a estado anterior
  def return_applicant_status_by(a_user)
    if solicitud_enviada?
      self.create_notification(a_user, "retornó a un estado anterior")
      self.solicitud_auditoria!
    else
      raise ArgumentError, "No es posible retornar a un estado anterior"
    end
  end

  def send_request_by(a_user)
    if self.solicitud_auditoria?
      self.solicitud_enviada!
      self.create_notification(a_user, "envió")
    else
      raise ArgumentError, 'La solicitud no se encuentra en auditoría.'
    end
  end

  def create_notification(of_user, action_type)
    ExternalOrderMovement.create(user: of_user, external_order: self, action: action_type, sector: of_user.sector)
    (self.applicant_sector.users.uniq - [of_user]).each do |user|
      @not = Notification.where( actor: of_user, user: user, target: self, notify_type: self.order_type, action_type: action_type, actor_sector: of_user.sector ).first_or_create
      @not.updated_at = DateTime.now
      @not.read_at = nil
      @not.save
    end
    (self.provider_sector.users.uniq - [of_user]).each do |user|
      @not = Notification.where( actor: of_user, user: user, target: self, notify_type: self.order_type, action_type: action_type, actor_sector: of_user.sector ).first_or_create
      @not.updated_at = DateTime.now
      @not.read_at = nil
      @not.save
    end
  end

  def get_statuses
    @statuses =self.class.statuses

    if self.solicitud?
      # si es anulado, devolvemos solo los 2 primeros estados y "anulado"
      if self.anulado?
        values = @statuses.except("proveedor_auditoria", "proveedor_aceptado", "provision_en_camino", "provision_entregada")
      else
        values = @statuses.except("anulado")
      end
    else
      values = @statuses.except("solicitud_auditoria", "solicitud_enviada", "anulado")
    end

    return values
  end

  # status: ["key_name", 0], trae dos valores, el nombre del estado y su valor entero del enum definido
  def set_status_class(status)
    status_class = self.anulado? ? "anulado" : "active";
    # obetenemos el valor del status del objeto. 
    self_status_int = ExternalOrder.statuses[self.status]
    return status[1] <= self_status_int ? status_class : ""
  end

  # Returns the name of the efetor who deliver the products
  def origin_name
    self.provider_sector.name+" "+self.provider_establishment.name
  end

  # Returns the name of the efetor who receive the products
  def destiny_name
    self.applicant_sector.name+" "+self.applicant_establishment.name
  end

  # Return the i18n model name
  def human_name
    self.class.model_name.human
  end

  private

  def record_remit_code
    if self.provision?
      self.remit_code = self.provider_sector.name[0..3].upcase+'des'+ExternalOrder.with_deleted.maximum(:id).to_i.next.to_s
    elsif self.solicitud?
      self.remit_code = self.applicant_sector.name[0..3].upcase+'sla'+ExternalOrder.with_deleted.maximum(:id).to_i.next.to_s
    end
  end
end
