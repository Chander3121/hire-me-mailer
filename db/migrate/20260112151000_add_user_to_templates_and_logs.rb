class AddUserToTemplatesAndLogs < ActiveRecord::Migration[7.0]
  def change
    add_reference :email_templates, :user, foreign_key: true
    add_reference :email_logs, :user, foreign_key: true
  end
end
