class OriginalChronicPrescriptionProductPolicy < ApplicationPolicy
  def edit? 
    record.total_delivered_quantity == 0
  end

  def finish_treatment?
    if record.pendiente?
      user.has_permission?(:complete_treatment_chronic_prescriptions)
    end
  end

  def update_treatment?
    finish_treatment?
  end

  def deliver?
    if record.pendiente?
      user.has_permission?(:dispense_chronic_prescriptions)
    end
  end
end
