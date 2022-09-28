class Product < ApplicationRecord
  include PgSearch::Model
  include EnumTranslation
  enum status: { active: 0, inactive: 1, merged: 2 }
  include QuerySort
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
  has_many :lots
  has_many :stocks

  # Validations
  validates_presence_of :name, :code, :area_id, :unity_id
  validates_uniqueness_of :code

  # Delegations

  delegate :term, :fsn, :concept_id, :semantic_tag, to: :snomed_concept, prefix: :snomed, allow_nil: true

  # Scopes

  scope :filter_by_stock, lambda { |filter_params|
    query = self.select(:id, :name, :code).where(id: Stock.where(sector_id: filter_params[:sector_id]).pluck(:product_id))
    if filter_params[:product]
      query = query.where('code like ? OR unaccent(lower(name)) like ?', "%#{filter_params[:product]}%", "%#{filter_params[:product].downcase.parameterize}%")
    end
    query = query.where.not(id: filter_params[:product_ids]) if filter_params[:product_ids]

    return query
  }

  scope :filter_by_params, lambda { |filter_params|
    query = self.select(:id, 'products.name as product_name', :status, :code, 'unities.name as unity_name', 'areas.name as area_name').joins(:unity, :area)
    query = query.like_code("%#{filter_params[:code]}%") if filter_params.present? && filter_params[:code].present?
    if filter_params.present? &&  filter_params[:name].present?

      query = query.like_name("%#{filter_params[:name].downcase.parameterize}% ")
    end
    query = if filter_params.present? && filter_params['sort'].present?
              query.sorted_by(filter_params['sort'])
            else
              query.reorder(code: :desc)
            end

    return query
  }

  scope :like_name, ->(product_name) { where('unaccent(lower(products.name))  like ?', product_name) }
  scope :like_code, ->(product_code) { where('code like ?', product_code) }

  def self.search_supply(a_name)
    Supply.search_text(a_name).with_pg_search_rank
  end
end
