class ProductPolicy < ApplicationPolicy

  def index?
    show?
  end

  def show?
    user.has_permission?(:read_products)
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
    if record.stocks.count.zero?
      user.has_permission?(:destroy_products)
    end
  end

  def delete?
    destroy?
  end

  def restore?
    destroy?
  end
end
