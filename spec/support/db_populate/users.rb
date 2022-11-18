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

  # Get 3 users with "in progress" status and complete request for test 
  # Actives sectors & active roles
  @user_build_from_pr = User.where(username: get_users_for_request).sample(3)
  @user_build_from_pr.each do |user|
    permission_request = user.permission_requests.in_progress.first
    user.user_sectors.build(sector_id: permission_request.sector_id, status: 'active')
    permission_request.aproved_by_id = [@farm_applicant, @depo_applicant, @farm_provider, @depo_provider].sample.id
    permission_request.done!
    permission_request.permission_request_roles.each do |prr|
      user.user_roles.build(role_id: prr.role.id, sector_id: permission_request.sector_id)
    end
    user.active!
  end

  @users_permission_requested = User.where(status: 'permission_req')
end
