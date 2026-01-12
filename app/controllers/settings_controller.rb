class SettingsController < ApplicationController
  before_action :ensure_authenticated_user
  skip_before_action :ensure_user_settings_present, only: [ :new, :create ]

  def new
    @setting = current_user.build_setting
  end

  def create
    @setting = current_user.build_setting(setting_params)
    if @setting.save
      current_user.update!(setting_present: true)
      redirect_to root_path, notice: "Settings saved successfully"
    else
      flash.now[:alert] = "Please fix errors below"
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @setting = current_user.setting
  end

  def update
    @setting = current_user.setting
    if @setting.update(setting_params)
      current_user.update!(setting_present: true)
      redirect_to root_path, notice: "Settings updated"
    else
      flash.now[:alert] = "Please fix errors below"
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def setting_params
    params.require(:setting).permit(:tinymce, :gmail_app_password, :email)
  end

  def ensure_authenticated_user
    # call Devise's authenticate_user! only if it's available
    if respond_to?(:authenticate_user!)
      authenticate_user!
    else
      # fallback: do nothing (assume unauthenticated flows are handled elsewhere)
      true
    end
  end
end
