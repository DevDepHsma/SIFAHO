def users_populate
  est_1 = Establishment.includes(:sectors).first
  est_2 = Establishment.includes(:sectors).second

  @farm_applicant = create(:user, username: '23456987', sector: est_1.sectors.first)
  @depo_applicant = create(:user, username: '24987456', sector: est_1.sectors.second)

  @farm_provider = create(:user, username: '23654789', sector: est_2.sectors.first)
  @depo_provider = create(:user, username: '24654789', sector: est_2.sectors.second)

  @user_requested = create(:user_1)
end
