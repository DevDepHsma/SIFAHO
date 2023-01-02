class PatientProductStateReportPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    index?
  end

  def create?
    true
  end

  def new?
    create?
  end
end