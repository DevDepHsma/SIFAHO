def users_populate
  @farm_applicant = create(:user, username: '23456987', sector: @farm_est_1)
  @depo_applicant = create(:user, username: '24987456', sector: @depo_est_1)

  @farm_provider = create(:user, username: '23654789', sector: @farm_est_2)
  @depo_provider = create(:user, username: '24654789', sector: @depo_est_2)

  @user_permission_requested = create(:user_1, username: '22638851')
  @role_sample = Role.all.sample
  @permission_request = PermissionRequest.create!(
    user_id: @user_permission_requested.id,
    status: 'in_progress',
    observation: 'Lorem ipsum',
    establishment_id: @farm_applicant.sector.establishment_id,
    sector_id: @farm_applicant.sector_id,
    role_ids: [@role_sample.id]
  )
end
