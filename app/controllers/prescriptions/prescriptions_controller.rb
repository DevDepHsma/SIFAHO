class PrescriptionsController < ApplicationController

  # GET /prescriptions
  # GET /prescriptions.json
  def index
    authorize Prescription
    @patient = Patient.new
  end

  def get_prescriptions
    @patient = Patient.find(params[:patient_id])
    @chronic_prescriptions = ChronicPrescription.where(patient_id: params[:patient_id]).order(updated_at: :desc).limit(10)
    @outpatient_prescriptions = OutpatientPrescription.where(patient_id: params[:patient_id]).order(updated_at: :desc).limit(10)
    @last_prescription = (@chronic_prescriptions + @outpatient_prescriptions).sort_by(&:updated_at).last
    respond_to do |format|
      format.js
    end
  end
end
