def efectors_populate(config)
  config.before(:all, type: :feature) do

    establishment_type = create(:hospital_establishment_type)
    
    @establishment = create(:hospital_establishment, establishment_type: establishment_type)
    @establishment = create(:establishment_1, establishment_type: establishment_type)
    @establishment = create(:establishment_2, establishment_type: establishment_type)
    
    @deposito = create(:sector_4, establishment: @establishment)
    @farmacia = create(:sector_1, establishment: @establishment)
    @user = create(:user_4, sector: @farmacia)
    @applicant_user = create(:user_1, sector: @farmacia)
    @provider_user = create(:user_2, sector: @deposito)

    
    # Farmacia other establishment
    @other_establishment = create(:establishment_2, sanitary_zone: iv_zone, establishment_type: establishment_type)
    @farmacia_other_establishment = create(:sector_4, establishment: @other_establishment)
    @farmacia_hja = create(:user_3, sector: @farmacia_other_establishment)
  

  
  end
end
