namespace :batch do
  desc 'Update lot status'
  task update_lot_status: :environment do
    Rails.logger.info 'Start update lot status. Vigentes: '+Lot.vigente.count.to_s+' Por vencer: '+Lot.por_vencer.count.to_s+' Vencido: '+Lot.vencido.count.to_s
    Lot.without_status(2).find_each do |lot| 
      lot.update_status
      lot.save!
    end
    Rails.logger.info 'Finished update lot status. Vigentes: '+Lot.vigente.count.to_s+' Por vencer: '+Lot.por_vencer.count.to_s+' Vencido: '+Lot.vencido.count.to_s
  end

  desc 'Update outpatient prescription status'
  task update_outpatient_prescription_status: :environment do
    Rails.logger.info 'Start update outpatient prescription status. Pendientes: '+OutpatientPrescription.pendiente.count.to_s+' Dispensadas: '+OutpatientPrescription.dispensada.count.to_s+' Vencidas: '+OutpatientPrescription.vencida.count.to_s
    OutpatientPrescription.find_each do |prescription| 
      prescription.update_status
      prescription.save(validate: false)
    end
    Rails.logger.info 'Finished update outpatient prescription status. Pendientes: '+OutpatientPrescription.pendiente.count.to_s+' Dispensadas: '+OutpatientPrescription.dispensada.count.to_s+' Vencidas: '+OutpatientPrescription.vencida.count.to_s
  end
end
