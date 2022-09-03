class ExternalOrderTemplatePolicy < ApplicationPolicy
  def index?
    user.has_permission?(:read_external_order_applicant) || user.has_permission?(:read_external_order_provider)
  end

  def destroy?
    true
    # if record.owner_sector == user.sector
    #   user.has_any_role?(:admin, :farmaceutico, :auxiliar_farmacia, :medic, :enfermero)
    # end
  end
end
