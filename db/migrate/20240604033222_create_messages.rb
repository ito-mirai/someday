class CreateMessages < ActiveRecord::Migration[7.0]
  def change
    create_table :messages do |t|
      t.text        :message, null: false
      t.integer     :speaker, null: false
      t.integer     :type, null: false
      t.references  :user, null: false, foreign_key: true
      t.timestamps
    end
  end
end
