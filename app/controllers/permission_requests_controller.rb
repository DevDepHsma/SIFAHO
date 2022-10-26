class PermissionRequestsController < ApplicationController
  before_action :set_permission_request, only: %i[show edit update destroy end]

  # GET /permission_requests
  # GET /permission_requests.json
  def index
    authorize PermissionRequest
    @filterrific = initialize_filterrific(
      PermissionRequest.where(status: 0).order(created_at: :desc),
      params[:filterrific],
      select_options: {
        sorted_by: PermissionRequest.options_for_sorted_by,
        for_statuses: PermissionRequest.options_for_status
      },
      persistence_id: false
    ) or return
    @permission_requests = @filterrific.find.paginate(page: params[:page], per_page: 21)
  end

  # GET /permission_requests/1
  # GET /permission_requests/1.json
  def show
    @user = @permission_request.user
    @sectors = Sector.joins(:establishment).pluck(:id, :name, 'establishments.name')
    @roles = if @user.has_role? :admin
               Role.all.order(:name).pluck(:id, :name)
             else
               Role.where.not(name: 'admin').order(:name).pluck(:id, :name)
             end
  end

  # GET /permission_requests/new
  def new
    authorize PermissionRequest
    @permission_request = PermissionRequest.new
    @establishments = Establishment.select(:id, :name).order(:name)
    @roles = Role.select(:id, :name).order(:name)
  end

  # POST /permission_requests
  # POST /permission_requests.json
  def create
    authorize PermissionRequest
    @permission_request = PermissionRequest.new(permission_request_params)
    @permission_request.user = @current_user

    respond_to do |format|
      if @permission_request.save
        format.html { redirect_to root_url, notice: 'Solicitud enviada.' }
          # format.json { render :show, status: :created, location: @permission_request }
      else
        @establishments = Establishment.select(:id, :name).order(:name)
        @roles = Role.select(:id, :name).order(:name)
        if @permission_request.establishment_id.to_i.positive?
          @sectors = Sector.select(:id,
                                   :name).where(establishment_id: @permission_request.establishment_id).order(:name)
        end
        format.html { render :new }
      end
    end
  end

  def request_sectors
    if params[:term].present? && params[:term].to_i.positive?
      @sectors = Sector.select(:id, :name).where(establishment_id: params[:term]).order(:name)
    end
    @permission_request = PermissionRequest.new
  end

  def request_in_progress
    authorize PermissionRequest
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_permission_request
    @permission_request = PermissionRequest.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def permission_request_params
    params.require(:permission_request).permit(
      :establishment_id,
      :other_establishment,
      :sector_id,
      :other_sector,
      { role_ids: [] },
      :observation
    )
  end
end
