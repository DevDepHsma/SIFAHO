def users_populate
  @farm_applicant = create(:user, username: '23456987', sector: @farm_est_1)
  @depo_applicant = create(:user, username: '24987456', sector: @depo_est_1)

  @farm_provider = create(:user, username: '23654789', sector: @farm_est_2)
  @depo_provider = create(:user, username: '24654789', sector: @depo_est_2)
end
