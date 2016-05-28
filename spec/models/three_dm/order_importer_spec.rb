require 'rails_helper'

describe ThreeDM::OrderImporter do
  let (:client) { FactoryGirl.create(:client) }
  let (:content) { File.read(Rails.root.join('spec', 'fixtures', 'files', '3dm_orders.csv')) }
  let (:importer) { ThreeDM::OrderImporter.new(content, client) }

  shared_context :books do
    let!(:bcd_10)  { FactoryGirl.create(:book, title: "Building A Discipling Culture (2nd Edition) Bundle of 10") }
    let!(:bdc)  { FactoryGirl.create(:book, title: "Building a Discipling Culture (2nd Edition)") }
    let!(:ffms)  { FactoryGirl.create(:book, title: "Five Fold Ministry Survey") }
    let!(:hlg)  { FactoryGirl.create(:book, title: "HBUNS Huddle Leader Guide") }
    let!(:hbuns)  { FactoryGirl.create(:book, title: "Huddle Bundle - Standard") }
    let!(:hpg)  { FactoryGirl.create(:book, title: "Huddle Participant Guide") }
    let!(:lkm)  { FactoryGirl.create(:book, title: "Leading Kingdom Movements") }
    let!(:ckp)  { FactoryGirl.create(:book, title: "Covenant & Kingdom - The DNA of the Bible") }
    let!(:lcbun)  { FactoryGirl.create(:book, title: "Learning Community Bundle") }
    let!(:lmc) { FactoryGirl.create(:book, title: "Leading Missional Communities") }
    let!(:mml) { FactoryGirl.create(:book, title: "Multiplying Missional Leaders") }
  end

  describe '#process' do
    it 'creates the specified order records' do
      expect do
        importer.process
      end.to change(Order, :count).by(5)
    end

    it 'creates the specified order item records' do
      expect do
        importer.process
      end.to change(OrderItem, :count).by(14)
    end

    context 'when books are defined' do
      include_context :books

      it 'resolves SKUs correctly' do
        importer.process
        order = Order.find_by(client_order_id: '35771')
        expect(order.items.map(&:sku)).to contain_exactly mml.isbn,
                                                          lkm.isbn,
                                                          lmc.isbn,
                                                          bdc.isbn,
                                                          lcbun.isbn,
                                                          ckp.isbn
      end
    end

    it 'consolodates line items having the same SKU'
  end
end
