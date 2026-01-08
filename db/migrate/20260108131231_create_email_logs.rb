class CreateEmailLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :email_logs do |t|
      t.string :email
      t.string :subject
      t.string :status
      t.datetime :sent_at

      t.timestamps
    end
  end
end
