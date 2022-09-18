class Report < ApplicationRecord
  belongs_to :sector
  belongs_to :generated_by_user, class_name: 'User'
  has_many :report_patients

  enum report_type: { by_patient: 1 }

  def build_report_values(args)
    set_by_patients(args) if by_patient?
  end

  def set_by_patients(args)
    opprescriptions = OutpatientPrescriptionProduct.get_delivery_products_by_patient({ sector_id: sector_id,
                                                                                       patient_ids: args[:patient_ids].split('_'),
                                                                                       product_ids: args[:product_ids].split('_') })
    opprescriptions.each do |opp|
      ReportPatient.create(
        report_id: id,
        product_id: opp.product_id,
        patient_id: opp.patient_id,
        product_code: opp.product_code,
        product_name: opp.product_name,
        product_quantity: opp.product_quantity,
        patient_dni: opp.patient_dni,
        patient_full_name: opp.patient_full_name,
        patient_age: ((Time.zone.now - opp.patient_birthdate.to_time) / 1.year.seconds).floor,
        patient_birthdate: opp.patient_birthdate
      )
    end
  end
end
