class PatientPolicy < ApplicationPolicy
  def index?
    show?
  end

  def show?
    user.has_permission?(:read_patients)
  end

  def create?
    user.has_permission?(:create_patients)
  end

  def new?
    create?
  end

  def update?
    user.has_permission?(:update_patients)
  end

  def edit?
    update?
  end

  def destroy?
    record.Temporal? && !record.chronic_prescriptions.any? && !record.outpatient_prescriptions.any? && user.has_permission?(:destroy_patients)
  end
end
