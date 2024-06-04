class RenameTypeColumnToMessages < ActiveRecord::Migration[7.0]
  def change
    rename_column :messages, :type, :message_type
  end
end
