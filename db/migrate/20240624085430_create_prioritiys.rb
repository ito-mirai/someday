class CreatePrioritiys < ActiveRecord::Migration[7.0]
  def change
    create_table :priorities do |t|

      t.timestamps
      t.integer     :weight,  null: false
      t.references  :task,    null: false, foreign_key: true
      t.references  :finish,  null: false, foreign_key: true
    end
  end
end
