def establishments_populate
  get_establishments.each do |establishment|
    create(:establishment,
           cuie: establishment[0],
           name: establishment[1],
           sanitary_zone_id:establishment[2],
           establishment_type_id:establishment[3]
        )
  end
end
