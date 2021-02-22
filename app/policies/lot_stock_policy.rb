class LotStockPolicy < ApplicationPolicy
  def index?
    user.has_any_role?(:admin)
  end

  def show?
    index?
  end

  def create?
    user.has_any_role?(:admin)
  end

  def new?
    create?
  end

  def restore?
    create?
  end

end