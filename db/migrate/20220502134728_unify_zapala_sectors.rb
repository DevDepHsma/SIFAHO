class UnifyZapalaSectors < ActiveRecord::Migration[5.2]
  def change
    @target = Sector.find(386)

    OutpatientPrescription.where(provider_sector_id: [450, 495, 507]).each do |op|
      op.provider_sector_id = @target.id
      op.save(validate: false)
    end

    ChronicPrescription.where(provider_sector_id: [450, 495, 507]).each do |cp|
      cp.provider_sector_id = @target.id
      cp.save(validate: false)
    end

    InternalOrder.where(applicant_sector_id: [450, 495, 507]).each do |cp|
      cp.applicant_sector_id = @target.id
      cp.save(validate: false)
    end

    InternalOrder.where(provider_sector_id: [450, 495, 507]).each do |cp|
      cp.provider_sector_id = @target.id
      cp.save(validate: false)
    end

    ExternalOrder.where(applicant_sector_id: [450, 495, 507]).each do |cp|
      cp.applicant_sector_id = @target.id
      cp.save(validate: false)
    end

    ExternalOrder.where(provider_sector_id: [450, 495, 507]).each do |cp|
      cp.provider_sector_id = @target.id
      cp.save(validate: false)
    end

    Stock.where(sector_id: [450, 495, 507]).each do |cp|
      cp.sector_id = @target.id
      cp.save(validate: false)
    end

    @target_ucc = Sector.find(394)
    OutpatientPrescription.where(provider_sector_id: 509).each do |op|
      op.provider_sector_id = @target_ucc.id
      op.save(validate: false)
    end

    ChronicPrescription.where(provider_sector_id: 509).each do |cp|
      cp.provider_sector_id = @target_ucc.id
      cp.save(validate: false)
    end

    InternalOrder.where(applicant_sector_id: 509).each do |cp|
      cp.applicant_sector_id = @target_ucc.id
      cp.save(validate: false)
    end

    InternalOrder.where(provider_sector_id: 509).each do |cp|
      cp.provider_sector_id = @target_ucc.id
      cp.save(validate: false)
    end

    ExternalOrder.where(applicant_sector_id: 509).each do |cp|
      cp.applicant_sector_id = @target_ucc.id
      cp.save(validate: false)
    end

    ExternalOrder.where(provider_sector_id: 509).each do |cp|
      cp.provider_sector_id = @target_ucc.id
      cp.save(validate: false)
    end

    Stock.where(sector_id: 509).each do |cp|
      cp.sector_id = @target_ucc.id
      cp.save(validate: false)
    end
  end
end
