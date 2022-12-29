class Sector < ApplicationRecord
  include PgSearch::Model

  # Relaciones
  belongs_to :establishment, counter_cache: true
  belongs_to :establishment, counter_cache: :sectors_count

  has_many :lot_stocks
  has_many :lots, -> { with_deleted }, through: :lot_stocks

  has_many :user_sectors
  has_many :users, through: :user_sectors
  has_many :reports, dependent: :destroy
  has_many :stocks
  has_many :beds, foreign_key: :service_id
  has_many :applicant_internal_orders, class_name: 'InternalOrder', foreign_key: :applicant_sector_id
  has_many :provider_internal_orders, class_name: 'InternalOrder', foreign_key: :provider_sector_id
  has_many :applicant_external_orders, class_name: 'ExternalOrder', foreign_key: :applicant_sector_id
  has_many :provider_external_orders, class_name: 'ExternalOrder', foreign_key: :provider_sector_id
  has_many :outpatient_prescriptons, class_name: 'OutpatientPrescription', foreign_key: :provider_sector_id
  has_many :chronic_dispensations, class_name: 'ChronicDispensation', foreign_key: :provider_sector_id
  has_many :chronic_prescriptions, class_name: 'ChronicPrescription', foreign_key: :provider_sector_id

  # Validaciones
  validates_presence_of :name, :establishment

  delegate :name, :short_name, to: :establishment, prefix: :establishment

  # SCOPES #--------------------------------------------------------------------
  pg_search_scope :search_name,
                  against: :name,
                  using: {
                    tsearch: { prefix: true } # Buscar coincidencia desde las primeras letras.
                  },
                  ignoring: :accents # Ignorar tildes.

  filterrific(
    default_filter_params: { sorted_by: 'name_asc' },
    available_filters: %i[
      search_name
      sorted_by
    ]
  )

  def self.options_for_select
    order('LOWER(name)').map { |e| [e.name, e.id] }
  end

  scope :sorted_by, lambda { |sort_option|
    # extract the sort direction from the param value.
    direction = sort_option =~ /desc$/ ? 'desc' : 'asc'
    case sort_option.to_s
    when /^created_at_/s
      # Ordenamiento por fecha de creación en la BD
      order("sectors.created_at #{direction}")
    when /^name_/s
      # Ordenamiento por fecha de creación en la BD
      order("sectors.name #{direction}")
    else
      # Si no existe la opcion de ordenamiento se levanta la excepcion
      raise(ArgumentError, "Invalid sort option: #{sort_option.inspect}")
    end
  }

  scope :with_establishment_id, lambda { |an_id|
    where(establishment_id: [*an_id])
  }

  scope :filter_by_internal_order, lambda { |filter_params|
    orders = by_stock(filter_params[:sector_id])
    query = where(id: orders.pluck(:applicant_sector_id).uniq)
    if filter_params[:sector].present?
      query = query.where('unaccent(lower(name)) like ?',
                          "%#{filter_params[:sector].downcase.parameterize(separator: ' ')}%")
    end
    query = query.where.not(id: filter_params[:sectors_ids]) if filter_params[:sectors_ids]
    return query
  }

  scope :by_stock, lambda { |sector_id|
    orders = InternalOrder.where(provider_sector_id: sector_id)
    return orders
  }
  scope :provide_hospitalization, -> { where(provide_hospitalization: true) }

  def establishment_name
    establishment.name
  end

  def sector_and_establishment
    name + ' de ' + establishment.name
  end

  def sum_delivered_external_order_quantities_to(a_supply, since_date, to_date)
    provider_ordering_quantity_supplies.where(supply: a_supply).entregado
                                       .dispensed_since(since_date)
                                       .dispensed_to(to_date)
                                       .sum(:delivered_quantity)
  end

  def sum_delivered_prescription_quantities_to(a_supply, since_date, to_date)
    provider_prescription_quantity_supplies.where(supply: a_supply).entregado
                                           .dispensed_since(since_date)
                                           .dispensed_to(to_date)
                                           .sum(:delivered_quantity)
  end

  def sum_delivered_internal_quantities_to(a_supply, since_date, to_date)
    provider_internal_quantity_supplies.where(supply: a_supply).entregado
                                       .dispensed_since(since_date)
                                       .dispensed_to(to_date)
                                       .sum(:delivered_quantity)
  end

  def delivered_external_order_quantities_by_establishment_to(a_supply)
    provider_ordering_quantity_supplies
      .where(supply: a_supply)
      .entregado
      .group(:quantifiable_id, :quantifiable_type).order('sum_amount DESC')
      .select(:quantifiable_id, :quantifiable_type, 'SUM(delivered_quantity) as sum_amount')
  end

  def stock_to(product_id)
    stock = stocks
            .where(product_id: product_id)
            .select(:quantity)
            .first

    stock.present? ? stock.quantity : 0
  end
end
