def effectors_populate
  establishment_1 = create(:establishment_1)
  establishment_2 = create(:establishment_2)

  @farm_est_1 = create(:sector_1, establishment: establishment_1)
  @depo_est_1 = create(:sector_2, establishment: establishment_1)

  @farm_est_2 = create(:sector_1, establishment: establishment_2)
  @depo_est_2 = create(:sector_2, establishment: establishment_2)
end
