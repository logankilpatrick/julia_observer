class RecreateLabels < ActiveRecord::Migration[5.1]
  def change
    create_table :labels do |t|
      t.references :subcategory, foreign_key: true
      t.references :package, foreign_key: true

      t.timestamps
    end

    add_index :labels, [:subcategory_id, :package_id], unique: true, name: 'index_labels_on_uniqueness'
  end
end
