class InternalOrderTemplateApplicantPolicy < InternalOrderTemplatePolicy
  def index?
    show?
  end

  def show?
    user.has_permission?(:read_internal_order_applicant)
  end

  def create?
    user.has_permission?(:create_internal_order_applicant)
  end

  def new?
    create?
  end

  def update?(resource)
    edit?(resource)
  end

  def edit?(resource)
    if resource.owner_sector == user.active_sector && resource.solicitud?
      user.has_permission?(:update_internal_order_applicant)
    end
  end

  def use_template?(resource)
    if resource.solicitud? && resource.owner_sector == user.active_sector
      user.has_permission?(:create_internal_order_applicant)
    end
  end
end
