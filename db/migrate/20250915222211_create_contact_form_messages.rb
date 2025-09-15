class CreateContactFormMessages < ActiveRecord::Migration[8.0]
  def change
    create_table :contact_form_messages do |t|
      t.string :email
      t.string :message
      t.string :subject

      t.timestamps
    end
  end
end
