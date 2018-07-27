class ProfessionalsController < ApplicationController
  before_action :set_professional, only: [:show, :edit, :update, :destroy, :delete]

  # GET /professionals
  # GET /professionals.json
  def index
    @filterrific = initialize_filterrific(
      Professional,
      params[:filterrific],
      select_options: {
        sorted_by: Professional.options_for_sorted_by,
        with_sector_id: Sector.options_for_select
      },
      persistence_id: false,
      default_filter_params: {sorted_by: 'created_at_desc'},
      available_filters: [
        :sorted_by,
        :search_query,
        :search_dni,
        :with_sector_id,
      ],
    ) or return
    @professionals = @filterrific.find.page(params[:page]).per_page(8)

    respond_to do |format|
      format.html
      format.js
    end
  end

  # GET /professionals/1
  # GET /professionals/1.json
  def show
    respond_to do |format|
      format.js
    end
  end

  # GET /professionals/new
  def new
    @professional = Professional.new
    @professional.build_sector
    @sectors = Sector.all
  end

  # GET /professionals/1/edit
  def edit
    @sectors = Sector.all
  end

  # POST /professionals
  # POST /professionals.json
  def create
    @professional = Professional.new(professional_params)

    respond_to do |format|
      if @professional.save
        flash.now[:success] = @professional.full_name+" se ha creado correctamente."
        format.js
      else
        flash.now[:error] = "El profesional no se ha podido crear."
        format.js
      end
    end
  end

  # PATCH/PUT /professionals/1
  # PATCH/PUT /professionals/1.json
  def update
    respond_to do |format|
      if @professional.update(professional_params)
        flash.now[:success] = @profesional.full_name+" se ha modificado correctamente."
        format.js
      else
        flash.now[:error] = @profesional.full_name+" no se ha podido modificar."
        format.js
      end
    end
  end

  # DELETE /professionals/1
  # DELETE /professionals/1.json
  def destroy
    @full_name = @professional.full_name
    @professional.destroy
    respond_to do |format|
      flash.now[:success] = @full_name+" se ha eliminado correctamente."
      format.js
    end
  end

  # GET /professional/1/delete
  def delete
    respond_to do |format|
      format.js
    end
  end

  def doctors
    @doctors = Professional.order(:first_name).search_query(params[:term]).limit(10)
    render json: @doctors.map{ |doc| { id: doc.id, dni: doc.dni, label: doc.fullname } }
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_professional
      @professional = Professional.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def professional_params
      params.require(:professional).permit(:first_name, :last_name, :professional_id,
                            :patient_id, :dni, :enrollment, :sector_id,
                            sector_attributes: [:id, :sector_name, :quantity,
                                                :complexity_level, :description])
    end
end
