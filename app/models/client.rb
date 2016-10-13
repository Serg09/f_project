# == Schema Information
#
# Table name: clients
#
#  id                           :integer          not null, primary key
#  name                         :string(100)      not null
#  abbreviation                 :string(5)        not null
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  order_import_processor_class :string(250)
#  auth_token                   :string(40)       not null
#

class Client < ActiveRecord::Base
  has_many :book_identifiers
  has_many :orders

  validates_presence_of :name, :abbreviation
  validates_length_of :name, maximum: 100
  validates_length_of :abbreviation, maximum: 5
  validates_length_of :order_import_processor_class, maximum: 250
  validates_uniqueness_of [:name, :abbreviation]

  before_create :ensure_auth_token

  scope :order_importers, ->{where('order_import_processor_class is not null')}

  def import_orders(content)
    raise 'No import processor class specified' unless order_import_processor_class.present?
    order_importer_class.new(content, self).process
  end

  private

  def ensure_auth_token
    self.auth_token ||= SecureRandom.uuid.gsub('-', '')
  end

  def order_importer_class
    order_import_processor_class.constantize
  end
end
