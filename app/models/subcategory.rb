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

class Subcategory < ApplicationRecord

  include Batchable

  extend FriendlyId
  friendly_id :name

  has_many :labels, dependent: :destroy
  has_many :packages, through: :labels

  belongs_to :category

  validates :name, presence: true, allow_blank: false

end
