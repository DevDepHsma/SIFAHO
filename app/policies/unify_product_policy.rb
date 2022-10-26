class UnifyProductPolicy < ApplicationPolicy
  def index?
    UnifyProductPolicy
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
    user.has_permission?(:update_products) unless record.merged?
  end

  def edit?
    update?
  end

  def apply?
    update?
  end

  def confirm_apply?
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
