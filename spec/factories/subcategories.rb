# == Schema Information
#
# Table name: subcategories
#
#  id          :integer          not null, primary key
#  name        :string
#  category_id :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_subcategories_on_category_id  (category_id)
#

FactoryGirl.define do
  factory :subcategory do
    name "MyString"
    category nil
  end
end
