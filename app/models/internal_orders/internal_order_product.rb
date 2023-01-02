class InternalOrderProduct < ApplicationRecord
  # Relationships
  belongs_to :order, class_name: 'InternalOrder', inverse_of: 'order_products'
  belongs_to :added_by_sector, class_name: 'Sector'
  has_many :order_prod_lot_stocks, dependent: :destroy, class_name: 'IntOrdProdLotStock',
                                   foreign_key: 'order_product_id', source: :int_ord_prod_lot_stocks,
                                   inverse_of: 'order_product'
  has_many :lot_stocks, through: :order_prod_lot_stocks

  include OrderProduct

  # Validations
  validates :delivery_quantity, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 },
                                if: proc { is_proveedor_auditoria? || is_provision_en_camino? }
  validate :out_of_stock, if: :is_provision_en_camino?
  validate :lot_stock_sum_quantity, if: :is_provision? && :is_provision_en_camino?
  validates :order_prod_lot_stocks, presence: { message: 'Debe seleccionar almenos 1 lote' },
                                    if: :is_provision_en_camino_and_quantity_greater_than_0?
  validates_associated :order_prod_lot_stocks, if: :is_provision_en_camino?

  # Scopes
  scope :agency_referrals, lambda { |id, city_town|
                             includes(client: :address).where(agency_id: id, 'client.address.city_town' => city_town)
                           }

  scope :ordered_products, -> { joins(:product).order('products.name DESC') }

  # new version
  def is_proveedor_auditoria?
    order.proveedor_auditoria?
  end

  def is_provision_en_camino?
    order.provision_en_camino?
  end

  def is_provision_en_camino_and_quantity_greater_than_0?
    order.provision_en_camino? && (delivery_quantity.present? && delivery_quantity > 0)
  end

  def is_provision?
    order.order_type == 'provision'
  end

  def is_solicitud?
    order.order_type == 'solicitud'
  end

  def is_solicitud_auditoria?
    order.solicitud_auditoria?
  end

  scope :get_delivery_products_by_sectors, lambda { |filter_params|
    sub_query_internal_orders = InternalOrder.where(provider_sector_id: filter_params[:sector_id])
    if filter_params[:sectors_ids].present?
      sub_query_internal_orders = sub_query_internal_orders.where(applicant_sector_id: filter_params[:sectors_ids])
    end

    if filter_params[:from_date].present?
      sub_query_internal_orders = sub_query_internal_orders.where('date(created_at) >= ?', filter_params[:from_date])
    end

    if filter_params[:to_date].present?
      sub_query_internal_orders = sub_query_internal_orders.where('date(created_at) <= ?', filter_params[:to_date])
    end
    query = select('SUM(delivery_quantity) as quantity',
                   'products.id as product_id',
                   'products.code as product_code',
                   'products.name as product_name',
                   'sectors.id as sector_id',
                   'sectors.name as sector_name')
            .joins(:order).joins('INNER JOIN sectors ON sectors.id=internal_orders.applicant_sector_id').joins(:product)
            .where(order_id: sub_query_internal_orders)
    query = query.where(product_id: filter_params[:products_ids]) if filter_params[:products_ids].present?
    
    query = query.group('sectors.id', 'products.id')
                 .order('sector_name ASC')
                 puts query.to_sql.colorize(background: :green)
    return query
  }
end
