class PrescriptionPolicy < ApplicationPolicy
  def index?
    user.has_permission?(:read_chronic_prescriptions) || user.has_permission?(:read_outpatient_recipes)
  end
end
