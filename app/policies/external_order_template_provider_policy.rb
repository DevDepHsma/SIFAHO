class ExternalOrderTemplateProviderPolicy < ExternalOrderTemplatePolicy
  def index?
    show?
  end

  def show?
    user.has_permission?(:read_external_order_provider)
  end

  def create?
    user.has_permission?(:create_external_order_provider)
  end

  def new?
    create?
  end

  def update?(resource)
    edit?(resource)
  end

  def edit?(resource)
    if resource.owner_sector == user.sector && resource.provision?
      user.has_permission?(:update_external_order_provider)
    end
  end

  def use_template?(resource)
    if resource.provision? && resource.owner_sector == user.sector
      user.has_permission?(:create_external_order_provider)
    end
  end
end
