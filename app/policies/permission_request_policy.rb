class PermissionRequestPolicy < ApplicationPolicy
  def index?
    user.has_permission?(:answer_permission_request)
  end

  def create?
    user.permissions.none? && user.permission_requests.none?(&:in_progress?)
  end

  def new?
    create?
  end

  def update?
    record.in_progress? && user.has_permission?(:answer_permission_request)
  end

  def edit?
    update?
  end

  def request_in_progress?
    user.permission_requests.any?(&:in_progress?)
  end
end