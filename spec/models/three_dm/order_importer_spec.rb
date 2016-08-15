require 'rails_helper'

describe ThreeDM::OrderImporter do
  let (:client) { FactoryGirl.create(:client) }
  let (:content) { File.read(Rails.root.join('spec', 'fixtures', 'files', '3dm_orders.csv')) }
  let (:importer) { ThreeDM::OrderImporter.new(content, client) }

  shared_context :books do
    let!(:bcd_10)  { FactoryGirl.create(:book, title: "Building A Discipling Culture (2nd Edition) Bundle of 10") }
    let!(:bcd_10_id) { bcd_10.identifiers.create!(client: client, code: 'BDC-10') }

    let!(:bdc)  { FactoryGirl.create(:book, title: "Building a Discipling Culture (2nd Edition)") }
    let!(:bcd_id) { bdc.identifiers.create!(client: client, code: 'BDC') }

    let!(:ffms)  { FactoryGirl.create(:book, title: "Five Fold Ministry Survey") }
    let!(:ffms_id) { ffms.identifiers.create!(client: client, code: 'FFMS') }

    let!(:hlg)  { FactoryGirl.create(:book, title: "HBUNS Huddle Leader Guide") }
    let!(:hlg_id) { hlg.identifiers.create!(client: client, code: 'HLG') }

    let!(:hbuns)  { FactoryGirl.create(:book, title: "Huddle Bundle - Standard") }
    let!(:hbuns_id) { hbuns.identifiers.create!(client: client, code: 'HBUNS') }

    let!(:hpg)  { FactoryGirl.create(:book, title: "Huddle Participant Guide") }
    let!(:hpg_id) { hpg.identifiers.create!(client: client, code: 'HPG') }

    let!(:lkm)  { FactoryGirl.create(:book, title: "Leading Kingdom Movements") }
    let!(:lkm_id) { lkm.identifiers.create!(client: client, code: 'LKM') }

    let!(:ckp)  { FactoryGirl.create(:book, title: "Covenant & Kingdom - The DNA of the Bible") }
    let!(:ckp_id) { ckp.identifiers.create!(client: client, code: 'CKP') }

    let!(:lcbun)  { FactoryGirl.create(:book, title: "Learning Community Bundle") }
    let!(:lcbun_id) { lcbun.identifiers.create!(client: client, code: 'LCBUN') }

    let!(:lmc) { FactoryGirl.create(:book, title: "Leading Missional Communities") }
    let!(:lmc_id) { lmc.identifiers.create!(client: client, code: 'LMC') }

    let!(:mml) { FactoryGirl.create(:book, title: "Multiplying Missional Leaders") }
    let!(:mml_id) { mml.identifiers.create!(client: client, code: 'MML') }
  end

  describe '#process' do
    include_context :books

    it 'creates the specified order records' do
      expect do
        importer.process
      end.to change(Order, :count).by(5)
    end

    it 'parses dates correctly' do
      importer.process
      expect(Order.find_by(client_order_id: '35771').order_date).to eq Date.new(2016, 5, 1)
    end

    it 'creates the specified order item records' do
      expect do
        importer.process
      end.to change(OrderItem, :count).by(14)
    end

    context 'when books are defined' do
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

    it 'consolodates line items having the same SKU' do
      importer.process
      order = Order.find_by(client_order_id: '35743')
      item = order.items.find_by(sku: hpg.isbn)
      expect(item.quantity).to eq 30
    end
  end
end
