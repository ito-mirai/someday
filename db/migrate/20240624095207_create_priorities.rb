class CreatePriorities < ActiveRecord::Migration[7.0]
  def change
    create_table :priorities do |t|

      t.integer     :weight, null: false
      t.references  :task, null: false, foreign_key: true
      t.timestamps
    end
  end
end
