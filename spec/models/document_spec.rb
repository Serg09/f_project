require 'rails_helper'

RSpec.describe Document, type: :model do
  let (:attributes) do
    {
      source: 'lsi',
      filename: 'PPO.M03021230',
      content: 'This is the content'
    }
  end

  it 'can be created from valid attributes' do
    document = Document.new attributes
    expect(document).to be_valid
  end

  describe '#source' do
    it 'is required' do
      document = Document.new attributes.except(:source)
      expect(document).to have_at_least(1).error_on :source
    end
  end

  describe '#filename' do
    it 'is required' do
      document = Document.new attributes.except(:filename)
      expect(document).to have_at_least(1).error_on :filename
    end
  end

  describe '#content' do
    it 'is required' do
      document = Document.new attributes.except(:content)
      expect(document).to have_at_least(1).error_on :content
    end
  end
end
