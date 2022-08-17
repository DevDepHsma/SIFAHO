def permisison_populate(config)
  config.before(:all, type: :feature) do
    get_permissions.each do |permission_mod|
      pm = create(:permission_module, name: permission_mod[0])
      permissions[1].each do |permission|
        create(:permission, name: permission, permission_module: pm)
      end
    end
  end
end
