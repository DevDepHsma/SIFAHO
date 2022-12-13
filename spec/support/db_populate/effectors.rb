def effectors_populate
  establishment_1 = create(:establishment_1)
  establishment_2 = create(:establishment_2)
  establishment_3 = create(:establishment_3)

  @farm_est_1 = create(:sector_1, establishment: establishment_1)
  @depo_est_1 = create(:sector_2, establishment: establishment_1)

  @farm_est_2 = create(:sector_1, establishment: establishment_2)
  @depo_est_2 = create(:sector_2, establishment: establishment_2)

  @farm_est_3 = create(:sector_1, establishment: establishment_3)
  @depo_est_3 = create(:sector_2, establishment: establishment_3)

  get_sectors.each do |sec_name|
    create(:sector, name: sec_name, establishment: establishment_1)
  end
  get_sectors.each do |sec_name|
    create(:sector, name: sec_name, establishment: establishment_3)
  end
end
