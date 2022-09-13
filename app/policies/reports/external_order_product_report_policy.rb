class ExternalOrderProductReportPolicy < ApplicationPolicy
  def show?
    user.has_permission?(:external_order_by_products)
  end

  def create?
    user.has_permission?(:external_order_by_products)
  end

  def new?
    create?
  end
end