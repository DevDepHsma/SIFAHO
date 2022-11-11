class PermissionsController < ApplicationController
  before_action :set_user, only: %i[edit update build_from_request]
  before_action :set_permission_request, only: %i[build_from_request edit]

  def build_from_request
    @user = @permission_request.build_user_permissions
    @roles = Role.all.order(name: :asc)
    @permission_modules = PermissionModule.eager_load(:permissions).all
    @sector = @permission_request.sector
    @enable_permissions = PermissionRole.where(role_id: @user.user_roles.map(&:role_id)).pluck(:permission_id)
    @applied_permission_request = @permission_request
  end

  def edit
    unless policy(:permission).edit?(@user)
      flash[:error] = 'Usted no está autorizado para realizar esta acción.'
      redirect_back(fallback_location: root_path)
    end
    @filterrific = initialize_filterrific(
      PermissionModule.eager_load(:permissions),
      params[:remote_form],
      persistence_id: false
    )
    @permission_modules = @filterrific.find
    @sector = @user.user_sectors.active.any? ? @user.user_sectors.active.first.sector : @user.sectors.first
    @enable_permissions = @user.permission_users.where(sector: @sector).pluck(:permission_id)
    @sectors = Sector.includes(:establishment)
                     .order('establishments.name ASC', 'sectors.name ASC')
                     .where.not(id: @user.sectors.pluck(:id))
    @roles = Role.all.order(name: :asc)
  end

  def update
    unless policy(:permission).update?(@user)
      flash[:error] = 'Usted no está autorizado para realizar esta acción.'
      redirect_back(fallback_location: root_path)
    end
    respond_to do |format|
      raise StandardError, 'Debe seleccionar un sector valido' unless params[:permission].present?

      @user.update_user_permissions!(permission_params, @current_user)
      flash.now[:success] = 'Permisos asignados correctamente.'
      format.js
      format.html { redirect_to users_admin_url(@user) }
    rescue ActiveRecord::RecordInvalid => e
      flash.now[:error] = e.record.errors.full_messages.to_sentence
    rescue StandardError => e
      flash.now[:error] = e.message
    ensure
      @filterrific = initialize_filterrific(
        PermissionModule.eager_load(:permissions),
        params[:remote_form],
        persistence_id: false
      )
      @sectors = Sector.includes(:establishment)
                       .order('establishments.name ASC', 'sectors.name ASC')
                       .where.not(id: @user.sectors.pluck(:id))
      @permission_modules = @filterrific.find
      @sector = params[:remote_form].present? ? Sector.find(params[:remote_form][:sector]) : @user.sector
      @enable_permissions = @user.permission_users.where(sector: @sector).pluck(:permission_id)
      # format.html { render :edit }
      format.js
    end
  end

  private

  def set_user
    @user = User.eager_load(:sectors).find(params[:id])
  end

  def set_permission_request
    @permission_request = @user.permission_requests.in_progress.last
  end

  def permission_params
    params.require(:permission).permit(
      :permission_request_id,
      user_sectors_attributes: %i[
        id
        sector_id
        _destroy
      ],
      permission_users_attributes: %i[
        id
        permission_id
        sector_id
        _destroy
      ],
      user_roles_attributes: %i[
        id
        role_id
        _destroy
      ]
    )
  end
end
