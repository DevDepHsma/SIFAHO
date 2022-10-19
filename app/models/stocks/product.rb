# == Schema Information

# Table name: products

# id                      :bigint   not null, primary key
# code                    :integer  not null
# name                    :string   not null
# status                  :integer  not null, by default 0
# description             :text     optional
# observation             :text     optional
# unity_id                :bigint   not null, unity
# area_id                 :bigint   not null, area
# snomed_concept_id       :bigint   optional
#

class Product < ApplicationRecord
  include PgSearch::Model
  include EnumTranslation
  include QuerySort
  enum status: { active: 0, inactive: 1, merged: 2 }
  # Relationships
  belongs_to :unity, optional: true
  belongs_to :area, optional: true
  belongs_to :snomed_concept, optional: true, counter_cache: :products_count
  has_many :stocks, dependent: :destroy
  has_many :external_order_product
  has_many :patient_product_state_reports
  has_one :origin_unify, class_name: 'UnifyProduct', foreign_key: 'origin_product_id'
  has_one :target_unify, class_name: 'UnifyProduct', foreign_key: 'target_product_id'
  has_many :chronic_prescription_products
  has_many :original_chronic_prescription_products
  has_many :inpatient_prescription_products
  has_many :external_order_products
  has_many :external_order_product_templates
  has_many :internal_order_products
  has_many :internal_order_product_templates
  has_many :outpatient_prescription_products
  has_many :receipt_products
  has_many :internal_order_product_reports
  has_many :monthly_consumption_reports
  has_many :patient_product_reports
  has_many :report_product_lines
  has_many :patient_product_state_reports
  has_many :lots, dependent: :delete_all
  has_many :stocks

  # Validations
  validates_presence_of :name, :code, :area_id, :unity_id
  validates_uniqueness_of :code

  # Delegations
  delegate :term, :fsn, :concept_id, :semantic_tag, to: :snomed_concept, prefix: :snomed, allow_nil: true
  before_save :format_downcase_degree
  # Scopes
  # Get all products with stock from a sector
  scope :filter_by_stock, lambda { |filter_params|
    query = self.select(:id, :name, :code).by_stock(filter_params[:sector_id])
    if filter_params[:product]
      query = query.like_code("%#{filter_params[:product]}%").or(query.like_name("%#{filter_params[:product].downcase.removeaccents}%"))      
    end
    query = query.where.not(id: filter_params[:products_ids]) if filter_params[:products_ids]

    return query
  }

  scope :filter_by_params, lambda { |filter_params|
    query = self.select(:id, 'products.name as product_name', :status, :code, 'unities.name as unity_name', 'areas.name as area_name').joins(:unity, :area)
    query = query.like_code("%#{filter_params[:code]}%") if filter_params.present? && filter_params[:code].present?
    if filter_params.present? &&  filter_params[:name].present?

      query = query.like_name("%#{filter_params[:name].downcase.removeaccents}%")
    end
    query = if filter_params.present? && filter_params['sort'].present?
              query.sorted_by(filter_params['sort'])
            else
              query.reorder(code: :desc)
            end

    return query
  }

  scope :by_stock, ->(sector_id) { where(id: Stock.where(sector_id: sector_id).pluck(:product_id)) }
  scope :like_name, ->(product_name) { where('unaccent(lower(products.name))  like ?', product_name) }
  scope :like_code, ->(product_code) { where('code::VARCHAR like ?', product_code) }
  scope :with_code, ->(product_code) { where('products.code = ?', product_code) }

  #### DEPRECATED #####

  pg_search_scope :search_name,
                  against: :name,
                  using: {
                    tsearch: { prefix: true } # Buscar coincidencia desde las primeras letras.
                  },
                  ignoring: :accents # Ignorar tildes.

  def self.search_supply(a_name)
    Supply.search_text(a_name).with_pg_search_rank
  end

  def format_downcase_degree
    self.name = name.downcase.to_degree
  end
end
