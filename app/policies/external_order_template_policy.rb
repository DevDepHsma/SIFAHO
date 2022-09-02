class ExternalOrderTemplatePolicy < ApplicationPolicy
  def index?
    show?
  end

  def show?
    user.has_permission?(:read_external_order_applicant) || user.has_permission?(:read_external_order_provider)
  end

  def create?
    user.has_permission?(:create_external_order_provider) || user.has_permission?(:create_external_order_provider)
  end

  def new?
    create?
  end

  def update?
    if record.owner_sector == user.sector
      user.has_any_role?(:admin, :farmaceutico, :auxiliar_farmacia, :medic, :enfermero)
    end
  end

  def destroy?
    if record.owner_sector == user.sector
      user.has_any_role?(:admin, :farmaceutico, :auxiliar_farmacia, :medic, :enfermero)
    end
  end
end