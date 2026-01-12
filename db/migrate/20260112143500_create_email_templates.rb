class CreateEmailTemplates < ActiveRecord::Migration[7.0]
  def change
    create_table :email_templates do |t|
      t.string :name, null: false
      t.text :content

      t.timestamps
    end

    add_index :email_templates, :name, unique: true
  end
end
