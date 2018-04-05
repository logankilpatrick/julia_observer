class UpdateReadmeForPackages < ActiveRecord::Migration[5.1]
  def up
    Package.all.each do |cur_package|
      readme_searchable, readme_trailing =
        Package.split_readme(cur_package.readme_searchable)

      cur_package.readme_searchable = readme_searchable
      cur_package.readme_trailing = readme_trailing

      cur_package.save!
    end
  end

  def down
    Package.all.each do |cur_package|
      next unless cur_package.readme_trailing.present?

      cur_package.readme_searchable += cur_package.readme_trailing
      cur_package.readme_trailing = nil

      cur_package.save!
    end
  end
end
