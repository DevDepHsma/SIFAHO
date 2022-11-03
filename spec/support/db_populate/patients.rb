def patients_populate
  @patients = get_patients.map do |patient|
    create(:patient, dni: patient[0], sex: patient[1], last_name: patient[2], first_name: patient[3],
                     marital_status: patient[4], birthdate: patient[5])
  end

  @patients_without_prescriptions = get_patients_without_prescriptions.map do |patient|
    create(:patient, dni: patient[0], sex: patient[1], last_name: patient[2], first_name: patient[3],
                     marital_status: patient[4], birthdate: patient[5])
  end
end

def outpatient_prescriptions_populate
  [@farm_applicant, @depo_applicant, @farm_provider].each do |user|
    OutpatientPrescription.statuses.each do |status|
      @patients.each_with_index do |patient, index|
        from_date = status[0] == 'vencida' ? (Time.now - 6.month) : (Time.now - 15.day)
        date_prescribed = time_rand(from_date)
        op = OutpatientPrescription.new(
          status: status[0],
          date_dispensed: date_prescribed.to_datetime,
          professional_id: Professional.all.sample.id,
          patient_id: patient.id,
          provider_sector_id: user.sector_id,
          establishment_id: user.sector.establishment_id,
          remit_code: "AM#{date_prescribed.to_datetime.to_s(:number)}-#{index}",
          date_prescribed: date_prescribed.to_datetime,
          expiry_date: (date_prescribed + 1.month).to_datetime,
          observation: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.'
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
    end
  end
end

def chronic_prescriptions_populate
  [@farm_applicant, @depo_applicant, @farm_provider].each do |user|
    @patients.each_with_index do |patient, index|
      from_date = Time.now - 15.day
      date_prescribed = time_rand(from_date)
      cp = ChronicPrescription.new(
        remit_code: "CR#{date_prescribed.to_datetime.to_s(:number)}-#{index}",
        date_prescribed: date_prescribed.to_datetime,
        expiry_date: (date_prescribed + 3.month).to_datetime,
        status: 'pendiente',
        diagnostic: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.',
        professional_id: Professional.all.sample.id,
        patient_id: patient.id,
        provider_sector_id: user.sector_id,
        establishment_id: user.sector.establishment_id
      )

      @products_to_dispense.each do |product|
        quantity = rand(2..5)
        ocp = OriginalChronicPrescriptionProduct.new(
          product_id: product.id,
          request_quantity: quantity,
          total_request_quantity: quantity * 3
        )
        cp.original_chronic_prescription_products << ocp
      end
      cp.save(validation: false)
    end
  end

  [@farm_applicant, @depo_applicant, @farm_provider].each do |user|
    cp_full_dispense = ChronicPrescription.where(provider_sector_id: user.sector_id).sample(2)

    cp_full_dispense.each do |cp|
      3.times do
        cdis = ChronicDispensation.new(
          chronic_prescription_id: cp.id,
          observation: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt.',
          status: 'dispensada',
          provider_sector_id: user.sector_id
        )

        cp.original_chronic_prescription_products.each do |ocpp|
          cdis.dispensation_types.build({
                                          original_chronic_prescription_product_id: ocpp.id,
                                          quantity: ocpp.request_quantity,
                                          chronic_prescription_products_attributes: [{
                                            original_chronic_prescription_product_id: ocpp.id,
                                            product_id: ocpp.product_id,
                                            delivery_quantity: ocpp.request_quantity,
                                            observation: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt.',
                                            order_prod_lot_stocks_attributes: [{
                                              quantity: ocpp.request_quantity,
                                              lot_stock_id: Stock.where(sector_id: user.sector_id,
                                                                        product_id: ocpp.product_id).first.lot_stocks.first.id
                                            }]
                                          }]
                                        })
          cdis.save!
        end
      end # times
      cp.dispensada!
    end

    cp_partial_dispense = ChronicPrescription.where(provider_sector_id: user.sector_id, status: 'pendiente').sample(2)

    cp_partial_dispense.each do |cp|
      cdis = ChronicDispensation.new(
        chronic_prescription_id: cp.id,
        observation: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt.',
        status: 'pendiente',
        provider_sector_id: user.sector_id
      )

      cp.original_chronic_prescription_products.each do |ocpp|
        cdis.dispensation_types.build({
                                        original_chronic_prescription_product_id: ocpp.id,
                                        quantity: ocpp.request_quantity,
                                        chronic_prescription_products_attributes: [{
                                          original_chronic_prescription_product_id: ocpp.id,
                                          product_id: ocpp.product_id,
                                          delivery_quantity: ocpp.request_quantity,
                                          observation: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt.',
                                          order_prod_lot_stocks_attributes: [{
                                            quantity: ocpp.request_quantity,
                                            lot_stock_id: Stock.where(sector_id: user.sector_id,
                                                                      product_id: ocpp.product_id).first.lot_stocks.first.id
                                          }]
                                        }]
                                      })
        cdis.save!
      end
      cp.dispensada_parcial!
    end
  end # each prescriptions
end
