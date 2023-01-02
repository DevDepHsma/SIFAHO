class PatientProductStateReportPolicy < ApplicationPolicy
  def index?
    user.has_permission?(:report_by_patient_and_province)
  end

  def show?
    index?
  end

  def create?
    user.has_permission?(:report_by_patient_and_province)
  end

  def new?
    create?
  end
end