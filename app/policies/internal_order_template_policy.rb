class InternalOrderTemplatePolicy < ApplicationPolicy
  def index?
    user.has_permission?(:read_internal_order_applicant) || user.has_permission?(:read_internal_order_provider)
  end

  def destroy?
    true
  end
end
