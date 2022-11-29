class InternalOrderTemplateProviderPolicy < InternalOrderTemplatePolicy
  def index?
    show?
  end

  def show?
    user.has_permission?(:read_internal_order_provider)
  end

  def create?
    user.has_permission?(:create_internal_order_provider)
  end

  def new?
    create?
  end

  def update?(resource)
    edit?(resource)
  end

  def edit?(resource)
    user.has_permission?(:update_internal_order_provider) if resource.owner_sector == user.active_sector && resource.provision?
  end

  def use_template?(resource)
    user.has_permission?(:create_internal_order_provider) if resource.provision? && resource.owner_sector == user.active_sector
  end
end
