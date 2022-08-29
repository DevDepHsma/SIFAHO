def roles_populate
  get_roles.each do |role|
    create(:role, name: role)
  end
end
