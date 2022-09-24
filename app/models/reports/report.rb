class Report < ApplicationRecord
  belongs_to :sector
  belongs_to :generated_by_user, class_name: 'User'
  has_many :report_patients

  enum report_type: { by_patient: 1 }

  def build_report_values(args)
    set_by_patients(args) if by_patient?
  end

  def set_by_patients(args)
    opproducts = OutpatientPrescriptionProduct.get_delivery_products_by_patient({ sector_id: sector_id,
                                                                                  patient_ids: args[:patient_ids].split('_'),
                                                                                  product_ids: args[:product_ids].split('_'),
                                                                                  all_products: args[:all_products],
                                                                                  all_patients: args[:all_patients] })

    cpproducts = ChronicPrescriptionProduct.get_delivery_products_by_patient({ sector_id: sector_id,
                                                                               patient_ids: args[:patient_ids].split('_'),
                                                                               product_ids: args[:product_ids].split('_'),
                                                                               all_products: args[:all_products],
                                                                               all_patients: args[:all_patients] })

    query = "SELECT
              SUM(t3.product_quantity) as product_quantity,
              t3.product_id,
              t3.patient_id,
              t3.product_code,
              t3.product_name,
              t3.patient_full_name,
              t3.patient_dni,
              t3.patient_birthdate,
              t3.patient_birthdate
            FROM (
              SELECT
                t1.product_id,
                t1.patient_id,
                t1.product_code,
                t1.product_name,
                t1.product_quantity,
                t1.patient_full_name,
                t1.patient_dni,
                t1.patient_birthdate
              FROM (#{opproducts.to_sql}) as t1
              UNION
              SELECT
                t2.product_id,
                t2.patient_id,
                t2.product_code,
                t2.product_name,
                t2.product_quantity,
                t2.patient_full_name,
                t2.patient_dni,
                t2.patient_birthdate
              FROM (#{cpproducts.to_sql}) as t2) as t3
            GROUP BY
              t3.patient_id,
              t3.product_id,
              t3.product_code,
              t3.product_name,
              t3.patient_full_name,
              t3.patient_dni,
              t3.patient_birthdate"
    dispensed_products = ActiveRecord::Base.connection.execute(query).entries

    dispensed_products.each do |dp|
      patient_age = ((Time.zone.now - dp['patient_birthdate'].to_time) / 1.year.seconds).floor if dp['patient_birthdate'].present?
      ReportPatient.create(
        report_id: id,
        product_id: dp['product_id'],
        patient_id: dp['patient_id'],
        product_code: dp['product_code'],
        product_name: dp['product_name'],
        product_quantity: dp['product_quantity'],
        patient_dni: dp['patient_dni'],
        patient_full_name: dp['patient_full_name'],
        patient_age: patient_age,
        patient_birthdate: dp['patient_birthdate']
      )
    end
  end
end
