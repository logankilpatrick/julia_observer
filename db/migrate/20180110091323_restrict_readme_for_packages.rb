class RestrictReadmeForPackages < ActiveRecord::Migration[5.1]
  def up
    change_column :packages, :readme_searchable, :text, :limit => 25000
  end

  def down
    change_column :packages, :readme_searchable, :text
  end
end
