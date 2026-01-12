class EmailTemplatesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_template, only: [:show, :update]

  def index
    @templates = current_user.email_templates.order(:name)
  end

  # returns plain content for AJAX
  def show
    render plain: @template.content.to_s
  end

  def create
    @template = current_user.email_templates.new(template_params)
    if @template.save
      redirect_to email_templates_path, notice: 'Template created'
    else
      @templates = current_user.email_templates.order(:name)
      render :index, status: :unprocessable_entity
    end
  end

  def update
    if @template.update(template_params)
      redirect_to email_templates_path, notice: 'Template updated'
    else
      @templates = current_user.email_templates.order(:name)
      render :index, status: :unprocessable_entity
    end
  end

  private

  def set_template
    @template = current_user.email_templates.find(params[:id])
  end

  def template_params
    params.require(:email_template).permit(:name, :content)
  end
end
