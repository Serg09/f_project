require 'rails_helper'

describe UpdateImportProcessor do
  let (:file_content) { File.read(Rails.root.join('spec', 'fixtures', 'files', 'lsi_purchase_order_acknowledgment_sample.txt')) }
  let (:remote_filename) { 'M030112304.PPR' }

  let (:order1) { FactoryGirl.create(:exported_order) }
  let!(:item1_1) { order1 << '1123456789' }
  let (:order2) { FactoryGirl.create(:exported_order) }
  let!(:item2_1) { order2 << '1123456789' }
  let!(:item2_2) { order2 << '123456987X' }
  let!(:batch) { FactoryGirl.create(:batch, orders: [order1, order2]) }

  let (:ftp) { double('ftp') }
  before(:each) do
    expect(Net::FTP).to receive(:open).and_yield ftp
    expect(ftp).to receive(:chdir).with('outgoing')
    expect(ftp).to receive(:list).and_return [remote_filename]
    expect(ftp).to receive(:gettextfile).and_return(file_content)
    allow(ftp).to receive(:delete)
  end

  describe '::perform' do
    context 'for records without errors' do
      it 'updates the status of the order to "processing"' do
        expect do
          UpdateImportProcessor.perform
          order1.reload
        end.to change(order1, :status).from('exported').to('processing')
      end

      it 'updates the status of the line items to "processing"' do
        expect do
          UpdateImportProcessor.perform
          item1_1.reload
        end.to change(item1_1, :status).from('new').to('processing')
      end

      it 'sets the accepted_quantity' do
        expect do
          UpdateImportProcessor.perform
          item1_1.reload
        end.to change(item1_1, :accepted_quantity).to(1)
      end
    end

    context 'for order error records' do
      it 'updates the status of the order to "rejected"' #do
      #  expect do
      #    UpdateImportProcessor.perform
      #    order2.reload
      #  end.to change(order2, :status).from('exported').to('rejected')
      #end

      it 'updates the errors attribute of the order' #do
      #  UpdateImportProcessor.perform
      #  order2.reload
      #  expect(order2.error).to eq 'Unrecognized ISBN'
      #end
    end

    context 'for item error records' do
      it 'updates the status of the item to "rejected"' do
        expect do
          UpdateImportProcessor.perform
          item2_2.reload
        end.to change(item2_2, :status).from('new').to('rejected')
      end
    end

    #TODO Decide if we need to do this
    it 'saves the file content to the database' do
      expect do
        UpdateImportProcessor.perform
      end.to change(Document, :count).by(1)
    end

    it 'deletes the remote file' do
      expect(ftp).to receive(:delete).with(remote_filename)
      UpdateImportProcessor.perform
    end
  end
end
