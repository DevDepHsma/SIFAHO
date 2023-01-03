class ReportPolicy < ApplicationPolicy
  def index?
    show?
  end

  def show?
    user.has_permission?(:read_reports)
  end

  def new?
    user.has_permission?(:report_by_patients) || user.has_permission?(:report_by_sectors) || user.has_permission?(:report_by_establishments)
  end

  def create?
    user.has_permission?(:report_by_patients) || user.has_permission?(:report_by_sectors) || user.has_permission?(:report_by_establishments)
  end

  def destroy?
    user.has_permission?(:destroy_reports)
  end

  def report_by?(type)
    user.has_permission?(type)
  end
end
