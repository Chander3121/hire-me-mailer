class EmailLogsController < ApplicationController
  def index
    @logs = EmailLog.order(created_at: :desc)
  end
end
