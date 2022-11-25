class UsersController < ApplicationController
  before_action :set_user,
                only: %I[show update change_sector edit_permissions update_permissions adds_sector removes_sector]

  def index
    authorize User
    @users = User.filter_by_params(params[:filter])
                 .paginate(page: params[:page], per_page: params[:per_page] || 15)
  end

  def show
    authorize @user
  end

  def change_sector
    authorize @user
    @sectors = @user.sectors.joins(:establishment).pluck(:id, :name, 'establishments.name')

    respond_to do |format|
      format.js
    end
  end

  def edit_permissions
    authorize @user
    @sectors = Sector.joins(:establishment).pluck(:id, :name, 'establishments.name')
    @enabled_sectors = @user.sectors.joins(:establishment).pluck(:id, :name, 'establishments.name')
    @professional = Professional.new
    @roles = if @user.has_role? :admin
               Role.all.order(:name).pluck(:id, :name)
             else
               Role.where.not(name: 'admin').order(:name).pluck(:id, :name)
             end
  end

  def update_permissions
    authorize @user

    respond_to do |format|
      if @user.update(user_params.except(:id))
        flash[:success] = "#{@user.full_name} se ha modificado correctamente."
        format.html { redirect_to action: 'show', id: @user.id }
      else
        flash[:error] = "#{@user.full_name} no se ha podido modificar."
        format.html { render :edit_permissions }
      end
    end
  end

  def update
    authorize @user

    respond_to do |format|
      if @user.update(user_params)
        flash[:success] = "Ahora estás en #{@user.sector_name} #{@user.sector_establishment_short_name}"
        format.js { render inline: 'location.reload();' }
      else
        flash[:error] = 'No se ha podido modificar el sector.'
        format.js { render inline: 'location.reload();' }
      end
    end
  end

  def adds_sector
    @active_sector = Sector.find(params[:remote_form][:sector])
    @user.user_sectors.build(sector_id: @active_sector.id)
    @roles = Role.all.order(name: :asc)
    @permission_modules = PermissionModule.eager_load(:permissions).all
    @enable_permissions = @user.permission_users.where(sector_id: @active_sector).pluck(:permission_id)
    @sectors = Sector.includes(:establishment)
                     .order('establishments.name ASC', 'sectors.name ASC')
                     .where.not(id: @user.user_sectors.pluck(:sector_id))
  end

  def removes_sector
    @user.user_sectors.where(sector_id: params[:sector_id]).first.destroy
    @user.permission_users.where(sector_id: params[:sector_id]).destroy_all

    @user.update!(sector: @user.sectors.first) if @user.sector_id == params[:sector_id].to_i

    @sectors = Sector.includes(:establishment)
                     .order('establishments.name ASC', 'sectors.name ASC')
                     .where.not(id: @user.sectors.pluck(:id))
    @sector = @user.sector if @user.sector.present?
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:id, :sector_id, sector_ids: [], role_ids: [])
  end
end
