class SectorsController < ApplicationController
  before_action :set_sector, only: %i[show new edit create update destroy delete]

  # GET /sectors
  # GET /sectors.json
  def index
    unless policy(:sector).sidebar_menu?
      flash[:error] = 'Usted no está autorizado para realizar esta acción.'
      redirect_back(fallback_location: root_path)
    end
    @filterrific = initialize_filterrific(
      @current_user.has_permission?(:read_other_establishments) ? Sector : Sector.where(establishment_id: @current_user.active_sector.establishment.id),
      params[:filterrific],
      persistence_id: false,
      available_filters: [
        :search_name
      ]
    ) or return
    @sectors = @filterrific.find.page(params[:page]).per_page(15)
    respond_to do |format|
      if policy(:sector).index?
        format.html
        format.js
      elsif policy(:internal_order_applicant).index?
        format.html { redirect_to internal_orders_applicants_path }
      elsif policy(:internal_order_provider).index?
        format.html { redirect_to internal_orders_providers_path }
      end
    end
  end

  # GET /sectors/1
  # GET /sectors/1.json
  def show
    authorize @sector
    respond_to do |format|
      format.html
      format.js
    end
  end

  # GET /sectors/new
  def new
    authorize @sector
    # @sector = Sector.new
  end

  # GET /sectors/1/edit
  def edit
    authorize @sector
  end

  # POST /sectors
  # POST /sectors.json
  def create
    authorize @sector
    @sector = Sector.new(sector_params)

    respond_to do |format|
      if @sector.save
        flash.now[:success] = "#{@sector.name} se ha creado correctamente."
        format.html { redirect_to @sector }
        format.js
      else
        flash[:error] = 'El sector no se ha podido crear.'
        format.html { render :new }
        format.js { render layout: false, content_type: 'text/javascript' }
      end
    end
  end

  # PATCH/PUT /sectors/1
  # PATCH/PUT /sectors/1.json
  def update
    authorize @sector
    respond_to do |format|
      if @sector.update(sector_params)
        flash.now[:success] = "#{@sector.name} se ha modificado correctamente."
        format.html { redirect_to @sector }
        format.js
      else
        flash.now[:error] = "#{@sector.name} no se ha podido modificar."
        format.html { render :edit }
        format.js
      end
    end
  end

  # DELETE /sectors/1
  # DELETE /sectors/1.json
  def destroy
    authorize @sector
    sector = @sector.name
    @sector.destroy
    respond_to do |format|
      flash.now[:success] = "El sector #{sector} se ha eliminado correctamente."
      format.js
    end
  end

  # GET /sector/1/delete
  def delete
    respond_to do |format|
      format.js
    end
  end

  def with_sector_id
    @sectors = Sector.order(:name).with_sector_id(params[:term])
  end

  def with_establishment_id
    @sectors = Sector.order(:name).with_establishment_id(params[:term])
    render json: @sectors.map { |sector| { label: sector.name, id: sector.id } }
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_sector
    @sector = params[:id].present? ? Sector.find(params[:id]) : Sector.new
    @establishments = Establishment.all
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def sector_params
    params.require(:sector).permit(
      :name,
      :establishment_id,
      :description,
      :provide_hospitalization
    )
  end
end
