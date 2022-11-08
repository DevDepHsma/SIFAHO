def users_populate
  @farm_applicant = create(:user, username: '23456987', sector: @farm_est_1)
  @depo_applicant = create(:user, username: '24987456', sector: @depo_est_1)

  @farm_provider = create(:user, username: '23654789', sector: @farm_est_2)
  @depo_provider = create(:user, username: '24654789', sector: @depo_est_2)

  get_users_for_request.each do |user|
    a_user = create(:user_1, username: user)
    role_sample = Role.all.sample
    PermissionRequest.create!(
      user_id: a_user.id,
      status: 'in_progress',
      observation: 'Lorem ipsum',
      establishment_id: @farm_applicant.sector.establishment_id,
      sector_id: @farm_applicant.sector_id,
      role_ids: [role_sample.id]
    )
  end
end
