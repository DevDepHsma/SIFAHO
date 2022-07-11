module PermissionRequestsHelper
  def permission_request_status_label(permission_request)
    if permission_request.in_progress?
      return "info"
    elsif permission_request.done?
      return "success"
    end
  end
end
