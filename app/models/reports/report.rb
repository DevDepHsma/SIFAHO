class Report < ApplicationRecord
  include QuerySort

  belongs_to :sector
  belongs_to :generated_by_user, class_name: 'User'
  has_many :report_patients

  enum report_type: { by_patient: 1 }

  scope :filter_by_params, lambda { |filter_params|
    query = self.select(:id, :name, :sector_name, :establishment_name, :generated_date, :report_type)
    if filter_params.present?
      # Name
      query = query.like_name(filter_params['name']) if filter_params['name'].present?
      # Sector name
      query = query.like_sector_name(filter_params['sector_name']) if filter_params['sector_name'].present?
      # Establishment name
      if filter_params['establishment_name'].present?
        query = query.like_establishment_name(filter_params['establishment_name'])
      end
      # Generated date
      query = query.like_generated_date(filter_params['generated_date']) if filter_params['generated_date'].present?
      # Report type
      query = query.like_report_type(filter_params['report_type']) if filter_params['report_type'].present?
    end

    query = if filter_params.present? && filter_params['sort'].present?
              query.sorted_by(filter_params['sort'])
            else
              query.reorder(generated_date: :desc)
            end
    return query
  }

  scope :like_name, lambda { |word|
    where('unaccent(lower(name)) like ?', "%#{word}%")
  }
  scope :like_sector_name, lambda { |word|
    where('unaccent(lower(sector_name)) like ?', "%#{word}%")
  }
  scope :like_establishment_name, lambda { |word|
    where('unaccent(lower(establishment_name)) like ?', "%#{word}%")
  }
  scope :like_generated_date, lambda { |reference_time|
    where('generated_date >= ?', reference_time)
  }
  scope :like_report_type, lambda { |reference_time|
    where('report_type = ?', reference_time)
  }

  def build_report_values(args)
    set_by_patients(args) if by_patient?
  end

  def set_by_patients(args)
    opproducts = OutpatientPrescriptionProduct.get_delivery_products_by_patient({ sector_id: sector_id,
                                                                                  patient_ids: args[:patient_ids].split('_'),
                                                                                  product_ids: args[:product_ids].split('_'),
                                                                                  all_products: args[:all_products],
                                                                                  all_patients: args[:all_patients],
                                                                                  from_date: args[:from_date],
                                                                                  to_date: args[:to_date] })

    cpproducts = ChronicPrescriptionProduct.get_delivery_products_by_patient({ sector_id: sector_id,
                                                                               patient_ids: args[:patient_ids].split('_'),
                                                                               product_ids: args[:product_ids].split('_'),
                                                                               all_products: args[:all_products],
                                                                               all_patients: args[:all_patients],
                                                                               from_date: args[:from_date],
                                                                               to_date: args[:to_date] })

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
      if dp['patient_birthdate'].present?
        patient_age = ((Time.zone.now - dp['patient_birthdate'].to_time) / 1.year.seconds).floor
      end
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
