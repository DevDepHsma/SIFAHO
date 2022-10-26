class SnomedConceptPolicy < ApplicationPolicy
  def index?
    user.has_permission?(:read_products)
  end

  def search?
    index?
  end

  def show?
    index?
  end

  def create?
    user.has_permission?(:create_products)
  end

  def new?
    create?
  end

  def update?
    user.has_permission?(:update_products)
  end

  def edit?
    update?
  end

  def destroy?
    user.has_permission?(:destroy_products)
  end

  def delete?
    destroy?
  end

  def restore?
    destroy?
  end
end
