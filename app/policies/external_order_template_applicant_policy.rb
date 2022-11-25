class ExternalOrderTemplateApplicantPolicy < ExternalOrderTemplatePolicy
  def index?
    show?
  end

  def show?
    user.has_permission?(:read_external_order_applicant)
  end

  def create?
    user.has_permission?(:create_external_order_applicant)
  end

  def new?
    create?
  end

  def update?(resource)
    edit?(resource)
  end

  def edit?(resource)
    if resource.owner_sector == user.active_sector && resource.solicitud?
      user.has_permission?(:update_external_order_applicant)
    end
  end

  def use_template?(resource)
    create? if resource.solicitud? && resource.owner_sector == user.active_sector
  end
end
