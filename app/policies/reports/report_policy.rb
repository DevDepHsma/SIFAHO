class ReportPolicy < ApplicationPolicy
  def index?
    show?
  end

  def show?
    user.has_permission?(:read_reports)
  end

  def new?
    user.has_permission?(:report_by_patients)
  end

  def create?
    user.has_permission?(:report_by_patients)
  end

  def destroy?
    user.has_permission?(:destroy_reports)
  end
end
