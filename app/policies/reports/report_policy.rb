class ReportPolicy < ApplicationPolicy
  def index?
    user.has_permission?(:report_by_external_order_by_products)
  end

  def show?
    index?
  end

  def create_delivered_by_order?
    create_roles.any? { |role| user.has_role?(role) }
  end

  def new_delivered_by_order?
    create_delivered_by_order?
  end

  def create_delivered_by_establishment?
    create_roles.any? { |role| user.has_role?(role) }
  end

  def new_delivered_by_establishment?
    create_delivered_by_establishment?
  end

  def destroy?
    destroy_roles.any? { |role| user.has_role?(role) }
  end

  def delete?
    destroy?
  end

  private

  def show_roles
    [ :admin, :farmaceutico, :auxiliar_farmacia, :farmaceutico_central ]
  end

  def create_roles
    [ :admin, :farmaceutico, :auxiliar_farmacia ]
  end

  def destroy_roles
    [ :admin ]
  end
end
