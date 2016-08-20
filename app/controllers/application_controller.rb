class ApplicationController < ActionController::Base

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery(with: :exception)

  # 加上自訂欄位到 Devise 的註冊和編輯頁面
  # Ref: https://ihower.tw/rails4/auth.html
  before_action(:configure_permitted_parameters, if: :devise_controller?)

  # 將不符合權限的 Request，透過 Exception 的方式導向首頁，並且顯示訊息
  # Ref: https://github.com/ryanb/cancan/wiki/exception-handling
  rescue_from CanCan::AccessDenied do |exception|
    redirect_to(root_url, :alert => exception.message)
  end

  protected

  # Use username to login instead of email address on devise gem
  # Ref: http://stackoverflow.com/a/21486039
  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_in) { |u| u.permit(:username, :password, :remember_me) }
    devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:realname, :username, :email, :phone, :password, :password_confirmation, :remember_me) }
    devise_parameter_sanitizer.for(:account_update) { |u| u.permit(:realname, :email, :phone, :password, :password_confirmation, :current_password) }
  end

  # 設定第一個註冊的 user 為 admin
  # Ref: http://deveede.logdown.com/posts/206943-use-deviserolify-cancan-control-permissions
  def after_sign_in_path_for(resource)
    if resource.is_a?(User)
      if User.count == 1
        resource.add_role(:admin)
      end
      resource
    end
    root_path
  end
end
