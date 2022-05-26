class LotProvenancePolicy < ApplicationPolicy
  def index?
    show?
  end

  def show?
    user.has_permission?(:read_lots_provenance)
  end

  def create?
    user.has_permission?(:create_lots_provenance)
  end

  def new?
    create?
  end

  def update?
    user.has_permission?(:update_lots_provenance)
  end

  def edit?
    update?
  end

  def destroy?
    user.has_permission?(:destroy_lots_provenance) unless record.lots.any?
  end

  def delete?
    destroy?
  end
end
