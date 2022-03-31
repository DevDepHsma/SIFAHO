class OriginalChronicPrescriptionProductPolicy < ApplicationPolicy
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
