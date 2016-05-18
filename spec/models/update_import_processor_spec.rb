require 'rails_helper'

describe UpdateImportProcessor do
  let (:file_content) { File.read(Rails.root.join('spec', 'fixtures', 'files', 'lsi_purchase_order_acknowledgment.txt')) }
  let (:remote_filename) { 'M030112304.PPR' }

  let (:order1) { FactoryGirl.create(:exported_order) }
  let (:order2) { FactoryGirl.create(:exported_order) }
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
    end

    context 'for records with errors' do
      it 'updates the status of the order to "error"' do
        expect do
          UpdateImportProcessor.perform
          order2.reload
        end.to change(order2, :status).from('exported').to('rejected')
      end

      it 'updates the errors attribute of the order' do
        UpdateImportProcessor.perform
        order2.reload
        expect(order2.error).to eq 'Unrecognized ISBN'
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
