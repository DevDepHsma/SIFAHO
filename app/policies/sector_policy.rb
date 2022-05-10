class SectorPolicy < ApplicationPolicy
  def index?
    show?
  end

  def show?
    user.has_permission?(:read_sectors) || user.has_permission?(:read_internal_order_applicant) || user.has_permission?(:read_internal_order_provider)
  end

  def new?
    create?
  end

  def create?
    user.has_permission?(:create_sectors)
  end

  def select_establishment?
    user.has_permission?(:create_to_other_establishment)
  end

  def edit?
    update?
  end

  def update?
    user.has_permission?(:update_sectors)
  end

  def destroy?
    if record.users.count.zero? &&
       record.applicant_internal_orders.count.zero? &&
       record.provider_internal_orders.count.zero? &&
       record.applicant_external_orders.count.zero? &&
       record.provider_external_orders.count.zero? &&
       record.outpatient_prescriptons.count.zero? &&
       record.chronic_dispensations.count.zero? &&
       record.chronic_prescriptions.count.zero? &&
       record.stocks.sum(:quantity).zero?
      user.has_permission?(:destroy_sectors)
    end
  end

  def delete?
    destroy?
  end
end
