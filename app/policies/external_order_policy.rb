class ExternalOrderPolicy < ApplicationPolicy
  def new_report?
    new_report.any? { |role| user.has_role?(role) }
  end

  def generate_report?
    new_report?
  end

end
