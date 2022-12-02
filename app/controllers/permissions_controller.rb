class PermissionsController < ApplicationController
  before_action :set_user, only: %i[edit update build_from_request permission_change_sector build_permission_from_role]
  before_action :set_permission_request, only: %i[build_from_request edit]

  def build_from_request
    @user = @permission_request.build_user_permissions
    @active_sector = @permission_request.sector

    user_roles_from_active_sector = @user.user_roles.select { |us| us.sector_id == @active_sector.id }
    @roles = Role.all.order(name: :asc)
    @permission_modules = PermissionModule.eager_load(:permissions).all
    @enable_permissions = PermissionRole.where(role_id: user_roles_from_active_sector.map(&:role_id)).pluck(:permission_id)
    @applied_permission_request = @permission_request
  end

  # Buid from role: build none persisted object.
  # Should consider the active sector
  def build_permission_from_role
    @enable_permissions = PermissionRole.where(role_id: params[:role_id]).pluck(:permission_id)
    respond_to do |format|
      format.json { render json: @enable_permissions}
    end
  end

  def permission_change_sector
    @roles = Role.all.order(name: :asc)
    @permission_modules = PermissionModule.eager_load(:permissions).all
    @active_sector = Sector.find(params[:active_sector_id])
    @enable_permissions = @user.permission_users.where(sector_id: @active_sector).pluck(:permission_id)
  end

  def edit
    unless policy(:permission).edit?(@user)
      flash[:error] = 'Usted no está autorizado para realizar esta acción.'
      redirect_back(fallback_location: root_path)
    end
    @permission_modules = PermissionModule.eager_load(:permissions).all
    @active_sector = @user.user_sectors.active.any? ? @user.user_sectors.active.first.sector : @user.sectors.first
    @enable_permissions = @user.permission_users.where(sector: @active_sector).pluck(:permission_id)
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
    rescue ActiveRecord::RecordInvalid => e
      flash.now[:error] = e.record.errors.full_messages.to_sentence
    rescue StandardError => e
      flash.now[:error] = e.message
    ensure
      @permission_modules = PermissionModule.eager_load(:permissions).all
      @active_sector = @user.active_sector
      @enable_permissions = @user.permission_users.where(sector: @active_sector).pluck(:permission_id)
      @roles = Role.all.order(name: :asc)
      format.js
    end
  end

  def reject_permission_request
    @permission_request = PermissionRequest.find(params[:pr_id])
    @permission_request.rejected!
    flash.now[:success] = 'Solicitud anulada correctamente.'
  end

  def finish_permission_request
    @permission_request = PermissionRequest.find(params[:pr_id])
    @permission_request.done!
    flash.now[:success] = 'Solicitud terminada correctamente.'
  end

  private

  def set_user
    @user = User.eager_load(:sectors).find(params[:id])
  end

  def set_permission_request
    @permission_request = @user.active_permission_request
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
        sector_id
        _destroy
      ]
    )
  end
end
