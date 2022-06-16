class LotPolicy < ApplicationPolicy
  def sidebar_menu?
    show? || user.has_permission?(:read_lots_provenance)
  end

  def index?
    show?
  end

  def show?
    user.has_permission?(:read_lots)
  end

  def create?
    user.has_permission?(:create_lots)
  end

  def new?
    create?
  end

  def update?
    user.has_permission?(:update_lots)
  end

  def edit?
    update?
  end

  def destroy?
    user.has_permission?(:destroy_lots) unless record.lot_stocks.any?
  end

  def delete?
    destroy?
  end

  def restore?
    destroy?
  end

  def trash_index?
    user.has_any_role?(:admin)
  end
end
