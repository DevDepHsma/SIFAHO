def users_populate
  @farm_applicant = create(:user, username: '23456987')
  UserSector.create(user_id: @farm_applicant.id, sector_id: @farm_est_1.id, status: 'active')
  @depo_applicant = create(:user, username: '24987456')
  UserSector.create(user_id: @depo_applicant.id, sector_id: @depo_est_1.id, status: 'active')

  @farm_provider = create(:user, username: '23654789')
  UserSector.create(user_id: @farm_provider.id, sector_id: @farm_est_2.id, status: 'active')
  @depo_provider = create(:user, username: '24654789')
  UserSector.create(user_id: @depo_provider.id, sector_id: @depo_est_2.id, status: 'active')

  @user_requested_accepted = create(:user, username: '26333313')
  get_users_for_request.each do |user|
    a_user = create(:user_1, username: user)
    role_sample = Role.all.sample
    PermissionRequest.create!(
      user_id: a_user.id,
      status: 'in_progress',
      observation: 'Lorem ipsum',
      establishment_id: @farm_applicant.active_sector.establishment_id,
      sector_id: @farm_applicant.active_sector.id,
      role_ids: [role_sample.id]
    )
  end

  # #Generate quantity needs for  users  pagination test
  get_users_for_other_establishment.each do |user|
    @farm_3 = create(:user, username: user)
    UserSector.create(user_id: @farm_3.id, sector_id: @farm_est_3.id, status: 'active')
    @depo_3 = create(:user, username: user.to_i + 1)
    UserSector.create(user_id: @depo_3.id, sector_id: @depo_est_3.id, status: 'active')
  end

  get_users_for_permission_request.each do |user|
    a_user = create(:user_1, username: user)
    role_sample = Role.all.sample
    PermissionRequest.create!(
      user_id: a_user.id,
      status: 'in_progress',
      observation: 'Lorem ipsum',
      establishment_id: -1,
      sector_id: -1,
      other_sector: 'informatica',
      other_establishment: 'A hospital',
      role_ids: [role_sample.id]
    )
  end

  # Get 3 users with "in progress" status and complete request for test
  # Actives sectors
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

  # Get 1 users with "in progress" status and complete request for test
  # Active roles
  @user_build_without_role = User.where(username: get_users_for_request, status: 'permission_req').sample
  permission_request = @user_build_without_role.permission_requests.in_progress.first
  @user_build_without_role.user_sectors.build(sector_id: permission_request.sector_id, status: 'active')
  permission_request.aproved_by_id = [@farm_applicant, @depo_applicant, @farm_provider, @depo_provider].sample.id
  permission_request.done!
  @user_build_without_role.active!

  @users_permission_requested = User.where(username: get_users_for_request, status: 'permission_req')

  # User for test acepted permission with active sector from sectors,
  role = Role.all.sample
  sector = Sector.all.sample
  UserSector.create(user_id: @user_requested_accepted.id, sector_id: sector.id, status: 'active')
  UserRole.create(user_id: @user_requested_accepted.id, role_id: role.id, sector_id: sector.id)
  role.permissions.each do |permission|
    PermissionUser.create(user_id: @user_requested_accepted.id,
                          sector_id: sector.id,
                          permission_id: permission.id)
  end
end
