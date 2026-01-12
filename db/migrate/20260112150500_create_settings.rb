class CreateSettings < ActiveRecord::Migration[7.0]
  def change
    create_table :settings do |t|
      t.references :user, null: false, foreign_key: true
      t.string :tinymce
      t.string :gmail_app_password
      t.string :email

      t.timestamps
    end
  end
end
