class LaboratoryPolicy < ApplicationPolicy
  def index?
    show?
  end

  def show?
    user.has_permission?(:read_laboratories)
  end

  def create?
    user.has_permission?(:create_laboratories)
  end

  def new?
    create?
  end

  def update?
    user.has_permission?(:update_laboratories)
  end

  def edit?
    update?
  end

  def destroy?
    user.has_permission?(:destroy_laboratories) if record.lots.count.zero?
  end

  def delete?
    destroy?
  end
end
