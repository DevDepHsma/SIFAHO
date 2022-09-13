class PatientProductReportPolicy < ApplicationPolicy
  def index?
    false
  end

  def show?
    index?
  end

  def create?
    user.has_any_role?(:admin, :farmaceutico, :auxiliar_farmacia, :medic, :enfermero)
  end

  def new?
    create?
  end
end
