class ApplicationController < ActionController::Base
  before_action :notifiction_set_as_read, :set_highlight_row, only: [:show]
  protect_from_forgery with: :exception
  before_action :authenticate_user!, :keep_params
  before_action :clean_params
  before_action :keep_params, only: [:index]
  before_action :set_current_user, if: :except_path?
  include Pundit::Authorization

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  rescue_from DeviseLdapAuthenticatable::LdapException do |exception|
    render text: exception, status: 500
  end

  def user_not_authorized
    flash[:error] = 'Usted no está autorizado para realizar esta acción.'
    redirect_to(request.referrer || root_path)
  end

  def set_current_user
    @current_user = User.includes(:profile, :sector).find(current_user.id)
  end

  def pundit_user
    User.includes(:permission_users, :permissions, :sector).find(@current_user.id)
  end

  # Exclede Init sessions path, because on login form and create a session current_user
  # doesn't exists.
  def except_path?
    !(controller_name == 'sessions' && %w[new create].include?(action_name))
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_in) do |u|
      u.permit({ roles: [] }, :password, :password_confirmation, :username)
    end
  end

  def set_highlight_row
    @highlight_row = params[:resaltar].present? ? params[:resaltar].to_i : -1
  end

  # clean sessions filter and page values
  def clean_params
    if (session[:controller].present? && session[:controller] != controller_path) || (session[:controller] == controller_path && %w[
      index show edit
    ].exclude?(action_name))
      session[:filter] = nil
      session[:page] = nil
      session[:per_page] = nil
    end
  end

  # keep_params: only in index actions
  # Store filters in session or retrive filters from session to params
  def keep_params
    if (params[:filter].present? || params[:page].present?) && params[:reset].nil?
      session[:filter] = params[:filter]
      session[:page] = params[:page]
      session[:per_page] = params[:per_page]
      session[:controller] = controller_path
    elsif (session[:filter].present? || session[:page].present?) && params[:reset].nil?
      params[:filter] = session[:filter]
      params[:page] = session[:page]
      params[:per_page] = session[:per_page]
    elsif params[:reset].present?
      params[:filter] = nil
      params[:page] = nil
      params[:per_page] = nil
      session[:filter] = nil
      session[:page] = nil
      session[:per_page] = nil
    end
  end

  private

  # Marcamos la notificacion comoo leida
  def notifiction_set_as_read
    Notification.read!(params[:notification_id]) if params[:notification_id].present?
  end
end
