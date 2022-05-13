class SanitaryZonePolicy < ApplicationPolicy
  def index?
    show?
  end

  def show?
    user.has_permission?(:read_sanitary_zones)
  end

  def new?
    create?
  end

  def create?
    user.has_permission?(:create_sanitary_zones)
  end

  def edit?
    update?
  end

  def update?
    user.has_permission?(:update_sanitary_zones)
  end

  def destroy?
    user.has_permission?(:destroy_sanitary_zones) unless record.establishments.any?
  end

  def delete?
    destroy?
  end
end
