class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  before_action :ensure_user_settings_present

  private

  def ensure_user_settings_present
    # Only proceed if Devise helpers exist and user is signed in
    return unless defined?(user_signed_in?) && user_signed_in?

    # don't redirect while managing settings (avoid loop)
    return if controller_name == "settings"

    # if Devise controller actions (sign_in/sign_up), skip
    if respond_to?(:devise_controller?) && devise_controller?
      return
    end

    # If user already has settings or setting_present flag, allow
    return if current_user.respond_to?(:setting_present) && current_user.setting_present
    return if current_user.setting.present?

    # redirect to new settings page
    redirect_to new_setting_path, alert: "Please configure your account settings before continuing."
  end
end
