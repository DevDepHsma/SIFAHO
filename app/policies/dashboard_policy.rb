class DashboardPolicy < ApplicationPolicy
  def sidebar?
    user.permissions.any?
  end

  def index?
    user.has_any_role?(:admin, :farmaceutico, :auxiliar_farmacia, :central_farmaceutico, :medico, :enfermero)
  end
end