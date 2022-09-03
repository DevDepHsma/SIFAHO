def professionals_populate
  get_professionals.each do |professional|
    create(:professional,
           first_name: professional[0],
           last_name: professional[1],
           fullname: professional[2],
           dni: professional[3],
           is_active: professional[4],
           sex: professional[5])
  end
  @professionals = Professional.all
  get_qualifications.each_with_index do |qualification, index|
    create(:qualification,
           name: qualification[0],
           code: qualification[1],
           professional_id: @professionals[index].id)
  @qualifications = Qualification.all
  end
end
