class SectorPolicy < ApplicationPolicy
  def index?
    show?
  end

  def show?
    user.has_permission?(:read_sectors) || user.has_permission?(:read_internal_order_applicant)
  end

  def new?
    destroy_roles.any? { |role| user.has_role?(role) }
  end

  def edit?
    destroy_roles.any? { |role| user.has_role?(role) }
  end


  def destroy?
    destroy_roles.any? { |role| user.has_role?(role) }
  end

  def delete?
    destroy?
  end

  private

  def show_roles
    [ :admin, :farmaceutico, :auxiliar_farmacia, :farmaceutico_central ]
  end

  def create_roles
    [ :admin, :farmaceutico, :auxiliar_farmacia ]
  end

  def destroy_roles
    [ :admin ]
  end
end
