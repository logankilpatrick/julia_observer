class ChangeReadmeForPackages < ActiveRecord::Migration[5.1]
  def change
    rename_column :packages, :readme, :readme_searchable
    add_column :packages, :readme_trailing, :text
  end
end
