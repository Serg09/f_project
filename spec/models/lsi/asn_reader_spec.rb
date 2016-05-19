require 'rails_helper'

describe Lsi::AsnReader do
  let (:file_path) { Rails.root.join('spec', 'fixtures', 'files', 'lsi_advanced_shipping_notification_sample.txt') }
  let (:content) { File.read(file_path) }
  describe '#read' do
    it 'returns the shipping records' do
      reader = Lsi::AsnReader.new(content)
      expect(reader.read).to have(5).items
    end
  end
end
