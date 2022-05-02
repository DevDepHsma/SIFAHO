class UnifyZapalaSectors < ActiveRecord::Migration[5.2]
  def change
    @target = Sector.find(386)
    @covid_19_2 = Sector.find(450)
    @covid_19_3 = Sector.find(495)
    @covid_19_pediatria = Sector.find(507)

    OutpatientPrescription.where(provider_sector_id: [@covid_19_2.id, @covid_19_3.id, @covid_19_pediatria.id]).each do |op|
      op.provider_sector_id = @target.id
      op.save(validate: false)
    end

    ChronicPrescription.where(provider_sector_id: [@covid_19_2.id, @covid_19_3.id, @covid_19_pediatria.id]).each do |cp|
      cp.provider_sector_id = @target.id
      cp.save(validate: false)
    end

    InternalOrder.where(applicant_sector_id: [@covid_19_2.id, @covid_19_3.id, @covid_19_pediatria.id]).each do |cp|
      cp.applicant_sector_id = @target.id
      cp.save(validate: false)
    end

    InternalOrder.where(provider_sector_id: [@covid_19_2.id, @covid_19_3.id, @covid_19_pediatria.id]).each do |cp|
      cp.provider_sector_id = @target.id
      cp.save(validate: false)
    end

    ExternalOrder.where(applicant_sector_id: [@covid_19_2.id, @covid_19_3.id, @covid_19_pediatria.id]).each do |cp|
      cp.applicant_sector_id = @target.id
      cp.save(validate: false)
    end

    ExternalOrder.where(provider_sector_id: [@covid_19_2.id, @covid_19_3.id, @covid_19_pediatria.id]).each do |cp|
      cp.provider_sector_id = @target.id
      cp.save(validate: false)
    end

    Stock.where(sector_id: [@covid_19_2.id, @covid_19_3.id, @covid_19_pediatria.id]).each do |cp|
      cp.sector_id = @target.id
      cp.save(validate: false)
    end

    @target_ucc = Sector.find(394)
    @ucc_itinerante = Sector.find(509)
    OutpatientPrescription.where(provider_sector_id: @ucc_itinerante.id).each do |op|
      op.provider_sector_id = @target_ucc.id
      op.save(validate: false)
    end

    ChronicPrescription.where(provider_sector_id: @ucc_itinerante.id).each do |cp|
      cp.provider_sector_id = @target_ucc.id
      cp.save(validate: false)
    end

    InternalOrder.where(applicant_sector_id: @ucc_itinerante.id).each do |cp|
      cp.applicant_sector_id = @target_ucc.id
      cp.save(validate: false)
    end

    InternalOrder.where(provider_sector_id: @ucc_itinerante.id).each do |cp|
      cp.provider_sector_id = @target_ucc.id
      cp.save(validate: false)
    end

    ExternalOrder.where(applicant_sector_id: @ucc_itinerante.id).each do |cp|
      cp.applicant_sector_id = @target_ucc.id
      cp.save(validate: false)
    end

    ExternalOrder.where(provider_sector_id: @ucc_itinerante.id).each do |cp|
      cp.provider_sector_id = @target_ucc.id
      cp.save(validate: false)
    end

    Stock.where(sector_id: @ucc_itinerante.id).each do |cp|
      cp.sector_id = @target_ucc.id
      cp.save(validate: false)
    end
  end
end
