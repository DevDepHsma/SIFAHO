class SectorPolicy < ApplicationPolicy
  def index?
    show?
  end

  def show?
    user.has_permission?(:read_sectors) || user.has_permission?(:read_internal_order_applicant) || user.has_permission?(:read_internal_order_provider)
  end

  def new?
    create?
  end

  def create?
    user.has_permission?(:create_sectors)
  end

  def select_establishment?
    user.has_permission?(:create_to_other_establishment)
  end

  def edit?
    update?
  end

  def update?
    user.has_permission?(:update_sectors)
  end

  def destroy?
    user.has_permission?(:destroy_sectors)
  end

  def delete?
    destroy?
  end
end
