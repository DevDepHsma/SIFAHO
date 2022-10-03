class ExternalOrderTemplatePolicy < ApplicationPolicy
  def index?
    user.has_permission?(:read_external_order_applicant) || user.has_permission?(:read_external_order_provider)
  end

  def destroy?
    true
  end
end
