class EstablishmentsController < ApplicationController
  before_action :set_establishment, only: %i[show edit update destroy delete]

  # GET /establishments
  # GET /establishments.json
  def index
    unless policy(:establishment).sidebar_menu?
      flash[:error] = 'Usted no está autorizado para realizar esta acción.'
      redirect_back(fallback_location: root_path)
    end
    @filterrific = initialize_filterrific(
      Establishment.select(:id, :cuie, :name, :establishment_type_id, 'SUM(sectors.user_sectors_count) AS total_users')
      .left_outer_joins(:sectors)
      .group(:id, :cuie, :name, :establishment_type_id),
      params[:filterrific],
      select_options: {
        sorted_by: Establishment.options_for_sorted_by
      },
      persistence_id: false
    ) or return
    @establishments = (request.format.xlsx? || request.format.pdf?) ? @filterrific.find : @filterrific.find.page(params[:page]).per(15)
    respond_to do |format|
      if policy(:establishment).index?
        format.html
        format.js
        format.xlsx { headers['Content-Disposition'] = "attachment; filename=\"Establecimientos_#{DateTime.now.strftime('%d-%m-%Y')}.xlsx\"" }
      elsif policy(:external_order_applicant).index?
        format.html { redirect_to external_orders_applicants_path }
      elsif policy(:external_order_provider).index?
        format.html { redirect_to external_orders_providers_path }
      end
    end
  end

  # GET /establishments/1
  # GET /establishments/1.json
  def show
    authorize @establishment
    respond_to do |format|
      format.html
      format.js
    end
  end

  # GET /establishments/new
  def new
    authorize Establishment
    @establishment = Establishment.new
  end

  # GET /establishments/1/edit
  def edit
    authorize @establishment
  end

  # POST /establishments
  # POST /establishments.json
  def create
    @establishment = Establishment.new(establishment_params)
    authorize @establishment
    respond_to do |format|
      if @establishment.save
        flash.now[:success] = "#{@establishment.name} se ha creado correctamente."
        format.html { redirect_to @establishment }
        format.js
      else
        flash[:error] = 'El establecimiento no se ha podido crear.'
        format.html { render :new }
        format.js { render layout: false, content_type: 'text/javascript' }
      end
    end
  end

  # PATCH/PUT /establishments/1
  # PATCH/PUT /establishments/1.json
  def update
    authorize @establishment
    respond_to do |format|
      if @establishment.update(establishment_params)
        flash.now[:success] = "#{@establishment.name} se ha modificado correctamente."
        format.html { redirect_to @establishment }
      else
        flash.now[:error] = "#{@establishment.name} no se ha podido modificar."
        format.html { render :edit }
      end
      format.js
    end
  end

  # DELETE /establishments/1
  # DELETE /establishments/1.json
  def destroy
    authorize @establishment
    flash.now[:success] = "El establecimiento #{@establishment.name} se ha eliminado correctamente."
    @establishment.destroy
    respond_to do |format|
      format.js
    end
  end

  def search_by_name
    @establishments = Establishment.order(:name).search_name(params[:term]).limit(10).where_not_id(current_user.sector.establishment_id)
    render json: @establishments.map { |est| { label: est.name, id: est.id } }
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_establishment
    @establishment = Establishment.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def establishment_params
    params.require(:establishment).permit(:sanitary_zone_id, :establishment_type_id, :cuie, :siisa, :code, :name,
                                          :short_name, :cuit, :email, :domicile, :phone, :image, :latitude, :longitude)
  end
end
