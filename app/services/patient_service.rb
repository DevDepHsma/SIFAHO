class PatientService
  def initialize(dni)
    @dni = dni || ''
    @token = ENV['ANDES_TOKEN']
    @andes_puco_url = ENV['ANDES_PUCO_URL']
    @andes_mpi_url = ENV['ANDES_MPI_URL']
  end

  def find_patients
    andes_patients = RestClient::Request.execute(method: :get, url: @andes_mpi_url,
                                                 verify_ssl: false,
                                                 timeout: 30, headers: {
                                                   'Authorization' => "JWT #{@token}",
                                                   params: { 'documento': @dni }
                                                 })

    JSON.parse(andes_patients).map do |pat|
      patient_photo_res = get_patient_photo_from_andes(pat['_id'], pat['fotoId'])
      patient_photo = (Base64.strict_encode64(patient_photo_res) if patient_photo_res.present?)
      {
        create: true,
        label: "#{pat['documento']} #{pat['apellido']} #{pat['nombre']}",
        dni: pat['documento'],
        lastname: pat['apellido'],
        firstname: pat['nombre'],
        fullname: "#{pat['apellido']} #{pat['nombre']}",
        sex: pat['genero'],
        status: pat['estado'],
        avatar: patient_photo,
        data: pat
      }
    end
  end

  def find_insurances
    return [] if @dni.empty?

    JSON.parse(RestClient::Request.execute(method: :get, url: @andes_puco_url,
                                           verify_ssl: false,
                                           timeout: 30, headers: {
                                             'Authorization' => "JWT #{@token}",
                                             params: { 'dni': @dni }
                                           }))
  end

  def get_patient_photo_from_andes(patient_id, patient_photo_id)
    return unless patient_photo_id

    RestClient::Request.execute(method: :get, url: "#{@andes_mpi_url}/#{patient_id}/foto/#{patient_photo_id}",
                                verify_ssl: false,
                                timeout: 30, headers: {
                                  'Authorization' => "JWT #{@token}"
                                })
  end
end
