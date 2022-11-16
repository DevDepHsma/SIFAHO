class InternalOrder < ApplicationRecord
  include PgSearch::Model
  include Order
  include EnumTranslation
  include QuerySort

  enum order_type: { provision: 0, solicitud: 1 }
  enum status: { solicitud_auditoria: 0, solicitud_enviada: 1, proveedor_auditoria: 2, provision_en_camino: 3,
                 provision_entregada: 4, anulado: 5 }

  # Relationships
  has_many :order_products, dependent: :destroy, class_name: 'InternalOrderProduct', foreign_key: 'order_id',
                            inverse_of: 'order'
  has_many :int_ord_prod_lot_stocks, through: :order_products, inverse_of: :order, source: :order_prod_lot_stocks
  has_many :movements, class_name: 'InternalOrderMovement'
  has_many :comments, class_name: 'InternalOrderComment', foreign_key: 'order_id'

  validates_associated :order_products

  # Nested attributes
  accepts_nested_attributes_for :order_products,
                                reject_if: proc { |attributes| attributes['product_id'].blank? },
                                allow_destroy: true

  scope :filter_by_params, lambda { |filter_params|
    query = self.select(:id, :requested_date, :date_received, :remit_code, :status, :provider_sector_id, :order_type, :applicant_sector_id, 'sectors.name')
    if filter_params.present? && filter_params[:provider].present?
      query = query.like_sector_name(filter_params[:provider])
    end

    if filter_params.present? && filter_params[:search_applicant].present?
      query = query.like_sector_name(filter_params[:search_applicant])
    end

    query = query.like_remit_code(filter_params[:code]) if filter_params.present? && filter_params[:code].present?
    if filter_params.present? && filter_params[:with_order_type].present?
      query = query.with_order_type(filter_params[:with_order_type])
    end
    if filter_params.present? && filter_params[:with_status].present?
      query = query.with_status(filter_params[:with_status])
    end

    query = if filter_params.present? && filter_params['sort'].present?
              query.sorted_by(filter_params['sort'])
            else
              query.reorder(remit_code: :desc)
            end

    return query
  }

  scope :by_applicant, lambda { |sector_id|
    joins(:provider_sector).where(applicant_sector_id: sector_id)
  }
  scope :by_provider, lambda { |sector_id|
    joins(:applicant_sector).where(provider_sector_id: sector_id)
  }

  scope :like_sector_name, lambda { |sector_name|
    where('unaccent(lower(sectors.name))  like ?', "%#{sector_name.downcase.removeaccents}%")
  }

  scope :like_remit_code, lambda { |remit_code|
                            where('unaccent(lower(remit_code)) like ?', "%#{remit_code.downcase.removeaccents}%")
                          }
  scope :with_order_type, lambda { |order_type|
                            where(order_type: order_type)
                          }
  scope :with_status, lambda { |status|
                        where(status: status)
                      }

  pg_search_scope :search_code,
                  against: :remit_code,
                  using: { tsearch: { prefix: true }, trigram: {} }, # Buscar coincidencia en cualquier parte del string
                  ignoring: :accents # Ignorar tildes.

  pg_search_scope :search_applicant,
                  associated_against: { applicant_sector: :name },
                  using: { tsearch: { prefix: true } }, # Buscar coincidencia desde las primeras letras.
                  ignoring: :accents # Ignorar tildes.

  pg_search_scope :search_provider,
                  associated_against: { provider_sector: :name },
                  using: { tsearch: { prefix: true } }, # Buscar coincidencia desde las primeras letras.
                  ignoring: :accents # Ignorar tildes.

  scope :date_received_since, lambda { |a_date|
    where('internal_orders.date_received >= ?', a_date)
  }

  scope :date_received_to, lambda { |a_date|
    where('internal_orders.date_received <= ?', a_date)
  }

  scope :requested_date_since, lambda { |a_date|
    where('internal_orders.requested_date >= ?', a_date)
  }

  scope :requested_date_to, lambda { |a_date|
    where('internal_orders.requested_date <= ?', a_date)
  }

  scope :with_order_type, lambda { |a_type|
    where('internal_orders.order_type = ?', a_type)
  }

  scope :with_status, lambda { |a_status|
    where('internal_orders.status = ?', a_status)
  }

  scope :without_status, lambda { |a_status|
    where.not('internal_orders.status = ?', a_status)
  }

  def self.applicant(a_sector)
    where(applicant_sector: a_sector)
  end

  def self.provider(a_sector)
    where(provider_sector: a_sector)
  end

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
      ['Fecha entregado (asc)', 'entregado_asc'],
      ['Cantidad (asc)', 'cantidad_asc']
    ]
  end

  def self.options_for_status
    [
      ['Todos', '', 'default'],
      ['Solicitud auditoria', 0, 'warning'],
      ['Solicitud enviada', 1, 'info'],
      ['Proveedor auditoria', 2, 'warning'],
      ['Provision en camino', 3, 'primary'],
      ['Provision entregada', 4, 'success'],
      ['Anulado', 5, 'danger']
    ]
  end

  def is_provider?(a_user)
    provider_sector == a_user.sector
  end

  def is_applicant?(a_user)
    applicant_sector == a_user.sector
  end

  def sum_to?(a_sector)
    applicant_sector == a_sector
  end

  def delivered_with_sector?(a_sector)
    provider_sector == a_sector || applicant_sector == a_sector if provision_en_camino? || provision_entregada?
  end

  # Método para retornar perdido a estado anterior
  def return_applicant_status_by(a_user)
    if solicitud_enviada?
      create_notification(a_user, 'retornó a un estado anterior')
      solicitud_auditoria!
    else
      raise ArgumentError, 'No es posible retornar a un estado anterior'
    end
  end

  def create_notification(of_user, action_type)
    InternalOrderMovement.create(user: of_user, internal_order: self, action: action_type, sector: of_user.sector)
    (applicant_sector.users.uniq - [of_user]).each do |user|
      @not = Notification.where(actor: of_user, user: user, target: self, notify_type: order_type,
                                action_type: action_type, actor_sector: of_user.sector).first_or_create
      @not.updated_at = DateTime.now
      @not.read_at = nil
      @not.save
    end
    (provider_sector.users.uniq - [of_user]).each do |user|
      @not = Notification.where(actor: of_user, user: user, target: self, notify_type: order_type,
                                action_type: action_type, actor_sector: of_user.sector).first_or_create
      @not.updated_at = DateTime.now
      @not.read_at = nil
      @not.save
    end
  end

  def get_statuses
    @statuses = self.class.statuses

    if solicitud?
      # si es anulado, devolvemos solo los 2 primeros estados y "anulado"
      if anulado?
        @statuses.except('proveedor_auditoria', 'provision_en_camino', 'provision_entregada')
      else
        @statuses.except('anulado')
      end
    else
      @statuses.except('solicitud_auditoria', 'solicitud_enviada', 'anulado')
    end
  end

  # status: ["key_name", 0], trae dos valores, el nombre del estado y su valor entero del enum definido
  def set_status_class(status)
    status_class = anulado? ? 'anulado' : 'active'
    # obetenemos el valor del status del objeto.
    self_status_int = InternalOrder.statuses[self.status]
    status[1] <= self_status_int ? status_class : ''
  end

  # Returns the name of the efetor who deliver the products
  def origin_name
    provider_sector.name
  end

  # Returns the name of the efetor who receive the products
  def destiny_name
    applicant_sector.name
  end

  private

  def record_remit_code
    self.remit_code = "SE#{DateTime.now.to_s(:number)}"
  end

  def presence_of_products_into_the_order
    errors.add(:presence_of_products_into_the_order, 'Debe agregar almenos 1 producto') if order_products.size == 0
  end
end
