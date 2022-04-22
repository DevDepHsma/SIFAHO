class EstablishmentPolicy < ApplicationPolicy
  def index?
    show?
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
    user.has_permission?(:destroy_establishments)
  end

  def delete?
    destroy?
  end
end
