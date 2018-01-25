class AddAccuracy < ActiveRecord::Migration[5.1]
  def change
    change_table :drivers do |t|
      t.column :accuracy, :decimal
    end
  end
end
