class Sector < ApplicationRecord
  include PgSearch::Model
  include QuerySort
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

  scope :filter_by_params, lambda { |filter_params, user|
    query = self.select(:id, :name, :establishment_id, 'establishments.name as establishment_name').joins(:establishment)
    query = query.like_name(filter_params[:name]) if filter_params.present? && filter_params[:name].present?

    if filter_params.present? && filter_params[:establishment_name].present? && user.has_permission?(:read_other_establishments)
      query = query.like_establishment_name(filter_params[:establishment_name])
    end

    unless user.has_permission?(:read_other_establishments)
      query = query.where(establishment_id: user.active_sector.establishment.id)
    end

    query = if filter_params.present? && filter_params['sort'].present?
              query.sorted_by(filter_params['sort'])
            else
              query.reorder(name: :desc)
            end

    return query
  }

  scope :like_name, lambda { |sector_name|
                      where('unaccent(lower(sectors.name))  like ?', "%#{sector_name.downcase.removeaccents}%")
                    }

  scope :like_establishment_name, lambda { |establishment_name|
    where('unaccent(lower(establishments.name))  like ?', "%#{establishment_name.downcase.removeaccents}%")
  }

  def self.options_for_select
    order('LOWER(name)').map { |e| [e.name, e.id] }
  end

  scope :with_establishment_id, lambda { |an_id|
    where(establishment_id: [*an_id])
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
