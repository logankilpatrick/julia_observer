class DestroyLabels < ActiveRecord::Migration[5.1]
  def change
    drop_table :labels
  end
end
