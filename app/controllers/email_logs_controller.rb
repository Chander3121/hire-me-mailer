class EmailLogsController < ApplicationController
  before_action :authenticate_user!

  def index
    @logs = current_user.email_logs.order(created_at: :desc)
  end
end
