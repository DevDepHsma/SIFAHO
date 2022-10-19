def patients_populate
  get_patients.each do |patient|
    create(:patient, dni: patient[0], sex: patient[1], last_name: patient[2], first_name: patient[3],
                     marital_status: patient[4])
  end
  @patients = Patient.all
end

def outpatient_prescriptions_populate
  [@farm_applicant, @depo_applicant, @farm_provider].each do |user|
    # ##Dispensada#####
    from_date = Time.now - 19.day
    @patients.each_with_index do |patient, index|
      date_prescribed = time_rand(from_date)
      op = OutpatientPrescription.new(
        status: 'dispensada',
        date_dispensed: date_prescribed.to_datetime,
        professional_id: Professional.all.sample.id,
        patient_id: patient.id,
        provider_sector_id: user.sector_id,
        establishment_id: user.sector.establishment_id,
        remit_code: "AM#{date_prescribed.to_datetime.to_s(:number)}-#{index}",
        date_prescribed: date_prescribed.to_datetime
      )

      @products_to_dispense.each do |product|
        quantity = rand(2..5)
        opp = OutpatientPrescriptionProduct.new(
          product_id: product.id,
          request_quantity: quantity,
          delivery_quantity: quantity
        )

        opp.order_prod_lot_stocks.build({
                                          quantity: quantity,
                                          lot_stock_id: Stock.where(sector_id: user.sector_id,
                                                                    product_id: product.id).first.lot_stocks.first.id
                                        })

        op.outpatient_prescription_products << opp
      end
      op.save!
    end

    # ##Vencida#####
    from_date = Time.now - 6.month
    @patients.each_with_index do |patient, index|
      date_prescribed = time_rand(from_date)
      op = OutpatientPrescription.new(
        status: 'vencida',
        date_dispensed: date_prescribed.to_datetime,
        professional_id: Professional.all.sample.id,
        patient_id: patient.id,
        provider_sector_id: user.sector_id,
        establishment_id: user.sector.establishment_id,
        remit_code: "AM#{date_prescribed.to_datetime.to_s(:number)}-#{index}",
        date_prescribed: date_prescribed.to_datetime
      )

      @products_to_dispense.each do |product|
        quantity = rand(2..5)
        opp = OutpatientPrescriptionProduct.new(
          product_id: product.id,
          request_quantity: quantity,
          delivery_quantity: quantity
        )

        opp.order_prod_lot_stocks.build({
                                          quantity: quantity,
                                          lot_stock_id: Stock.where(sector_id: user.sector_id,
                                                                    product_id: product.id).first.lot_stocks.first.id
                                        })

        op.outpatient_prescription_products << opp
      end
      op.save(validation: false)
    end
    # ##Pendiente#####
    from_date = Time.now - 15.day
    @patients.each_with_index do |patient, index|
      date_prescribed = time_rand(from_date)
      op = OutpatientPrescription.new(
        status: 'pendiente',
        date_dispensed: date_prescribed.to_datetime,
        professional_id: Professional.all.sample.id,
        patient_id: patient.id,
        provider_sector_id: user.sector_id,
        establishment_id: user.sector.establishment_id,
        remit_code: "AM#{date_prescribed.to_datetime.to_s(:number)}-#{index}",
        date_prescribed: date_prescribed.to_datetime
      )

      @products_to_dispense.each do |product|
        quantity = rand(2..5)
        opp = OutpatientPrescriptionProduct.new(
          product_id: product.id,
          request_quantity: quantity,
          delivery_quantity: quantity
        )

        opp.order_prod_lot_stocks.build({
                                          quantity: quantity,
                                          lot_stock_id: Stock.where(sector_id: user.sector_id,
                                                                    product_id: product.id).first.lot_stocks.first.id
                                        })

        op.outpatient_prescription_products << opp
      end
      op.save!
    end
  end
end
