class ApplicationController < ActionController::Base
  before_action :notifiction_set_as_read, :set_highlight_row, only: [:show]
  protect_from_forgery with: :exception
  before_action :authenticate_user!, :keep_params
  before_action :set_current_user, if: :not_excluded_path?
  # before_action :configure_permitted_parameters, if: :devise_controller?
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
    # @current_user ||= super && User.includes(:profile, :sector).find(@current_user.id)
  end

  def pundit_user
    User.includes(:permission_users).includes(:permissions).includes(:sector).find(@current_user.id)
  end

  def not_excluded_path?
    request.path != user_session_path && request.method != 'POST'
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

  # keep_params:
  # en este metodo se busca mantener los parametros de filtros y/o de paginacion
  # segun el controlador visitado.
  # El caso en que se debe aplicar es cuando se quiere mantener los filtros o paginacion aplicada de un listado
  # luego de haber realizado otra accion como lo es agregar / editar
  def keep_params
    # visita de cualquier ruta
    session[:my_url_controller] ||= '' # inicializamos la variable del controlador
    ignore_action = %w[search_by_last_name search_by_first_name search_by_name] # definimos cuales acciones queremos ignorar
    # reiniciamos variables segun control:
    # si el controlador cambio (en cada request)
    # y si el request no se encuentra en la variable ignore_action
    if session[:my_url_controller] != params[:controller] && !ignore_action.include?(params[:action]) && (!defined?(params[:keep_params]) || (defined?(params[:keep_params]) && !params[:keep_params]))
      session[:my_url_controller] = params[:controller]
      session[:filterrific] = nil
      session[:page] = nil
    elsif session[:my_url_controller] == params[:controller] && %w[index
                                                                   lot_stocks_by_stock].include?(params[:action])
      # en caso de que el controlador se el mismo, la unica accion que puede modificar tanto los filtros como el paginador es el index
      # entonces es aqui donde modificamos los valores mencionados

      # seteamos el valor de filterrific segun control:
      # si :filterrific esta presente en params
      # y si el mismo valor es diferente al que esta guardado en session
      if params[:filterrific].present? && (params[:filterrific] != session[:filterrific])
        session[:filterrific] = params[:filterrific]
        session[:page] = nil # debemos tener en cuenta que si se filtra hay que reiniciar el valor de :page
      else
        # si no se aplico algun filtro:
        # solo pisamos el valor de :page, con su nuevo valor (si viene params[:page]) o con su valor de session
        session[:page] = params[:page].present? ? params[:page] : session[:page]
      end
    elsif params[:filterrific].present? && (params[:filterrific] != session[:filterrific]) && (defined?(params[:keep_params]) && params[:keep_params])
      session[:my_url_controller] = params[:controller] # debemos setear el controlador para que la próxima llamada (filtros) pueda filtrar
      session[:filterrific] = params[:filterrific]
      session[:page] = nil # debemos tener en cuenta que si se filtra hay que reiniciar el valor de :page
    end

    # por ultimo igualamos los valores de params con los de session
    # igualamos el valor :filterrific de params con el de session
    if params[:reset] == 'true'
      params[:filterrific] = nil
      session[:filterrific] = nil
    else
      params[:filterrific] = session[:filterrific]
    end
    # igualamos el valor :page de params con el de session
    params[:page] = session[:page]
  end

  private

  # Marcamos la notificacion comoo leida
  def notifiction_set_as_read
    Notification.read!(params[:notification_id]) if params[:notification_id].present?
  end
end
