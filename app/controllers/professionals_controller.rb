class ProfessionalsController < ApplicationController
  before_action :set_professional, only: %i[show edit update destroy delete]

  # GET /professionals
  # GET /professionals.json
  def index
    authorize Professional
    @filterrific = initialize_filterrific(
      Professional,
      params[:filterrific],
      select_options: {
        sorted_by: Professional.options_for_sorted_by
      },
      persistence_id: false
    ) or return
    @professionals = @filterrific.find.page(params[:page]).per_page(15)
    respond_to do |format|
      format.html
      format.js
      format.json { render json: @professionals.map{ |doc| { id: doc.id, label: "#{doc.qualifications.first.code} #{doc.last_name} #{doc.first_name}" } } }
    end
  end

  # GET /professionals/1
  # GET /professionals/1.json
  def show
    authorize @professional
    respond_to do |format|
      format.html
      format.js
    end
  end

  # GET /professionals/new
  def new
    authorize Professional
    @professional = params[:id].present? ? Professional.find(params[:id]) : Professional.new
    respond_to do |format|
      format.html
      format.js
    end
  end

  # GET /professionals/1/edit
  def edit
    authorize @professional
  end

  # POST /professionals
  # POST /professionals.json
  def create
    @professional = Professional.find(professional_params[:id]) if professional_params[:id].present?
    @professional = Professional.find_by(dni: professional_params[:dni]) unless @professional.present?
    respond_to do |format|
      if @professional.present?
        @professional.update(professional_params.merge(id: @professional.id))
        flash.now[:success] = "#{@professional.fullname} se ha actualizado correctamente."
      else
        @professional = Professional.new(professional_params)
        authorize @professional
        @professional.save!
        flash.now[:success] = "#{@professional.fullname} se ha creado correctamente."
      end
      format.html { redirect_to @professional }
      format.js
    end
  end

  # PATCH/PUT /professionals/1
  # PATCH/PUT /professionals/1.json
  def update
    authorize @professional
    respond_to do |format|
      if @professional.update(professional_params)
        flash[:success] = "#{@professional.fullname} se ha modificado correctamente."
        format.html { redirect_to @professional }
      else
        flash[:error] = "#{@professional.fullname} no se ha podido modificar."
        format.html { redirect_to @professional }
      end
    end
  end

  # DELETE /professionals/1
  # DELETE /professionals/1.json
  def destroy
    authorize @professional
    @fullname = @professional.fullname
    @professional.destroy
    respond_to do |format|
      flash.now[:success] = @fullname+" se ha eliminado correctamente."
      format.js
    end
  end

  def get_by_enrollment_and_fullname
    @professionals = ProfessionalCreator.new(params).find_practitioner
    respond_to do |format|
      format.js { render :professional_list, locals: { is_remote: true } }
    end
  end

  def get_by_enrollment_and_fullname_html
    @professionals = ProfessionalCreator.new(params).find_practitioner
    respond_to do |format|
      format.js { render :professional_list, locals: { is_remote: false } }
    end
  end

  def get_by_unsigned_enrollment_fullname
    @doctors = Professional.without_user_asigned.get_by_enrollment_and_fullname(params[:term]).limit(10).order(:last_name)
    render json: @doctors.map{ |doc| { id: doc.id, label: "#{doc.enrollment} #{doc.last_name} #{doc.first_name}" } }
  end

  def asign_user
    respond_to do |format|
      @professional = Professional.find(params[:professional_id])
      if @professional.update(user_id: params[:user_id])
        flash[:success] = "#{@professional.fullname} se ha modificado correctamente."
        format.js
      else
        flash[:error] = 'No se ha podido modificar el profesional.'
        format.js { render :asign_user_error }
      end
    end
  end

  def doctors
    @doctors = Professional.order(:first_name).search_professional(params[:term]).limit(10)
    render json: @doctors.map{ |doc| { id: doc.id, dni: doc.dni, label: doc.fullname, enrollment: doc.enrollment } }
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_professional
    @professional = Professional.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def professional_params
    params.require(:professional).permit(
      :id,
      :first_name,
      :last_name,
      :dni,
      :enrollment,
      :is_active,
      :fullname,
      :sex,
      qualifications_attributes: [
        :professional_id,
        :name,
        :code
      ])
  end
end
