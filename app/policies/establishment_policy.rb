class EstablishmentPolicy < ApplicationPolicy
  def index?
    show?
  end

  def sidebar_menu?
    user.has_permission?(:read_establishments) || user.has_permission?(:read_external_order_applicant) || user.has_permission?(:read_external_order_provider)
  end

  def show?
    user.has_permission?(:read_establishments)
  end

  def create?
    user.has_permission?(:create_establishments)
  end

  def new?
    create?
  end

  def update?
    user.has_permission?(:update_establishments)
  end

  def edit?
    update?
  end

  def destroy?
    user.has_permission?(:destroy_establishments) unless record.sectors.exists? || record.users.exists?
  end

  def delete?
    destroy?
  end
end
