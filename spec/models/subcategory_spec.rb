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

require 'rails_helper'

RSpec.describe Subcategory, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
