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
    user.has_permission?(:destroy_patients)
  end
end
