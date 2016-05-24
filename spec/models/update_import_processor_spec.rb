require 'rails_helper'

describe UpdateImportProcessor do
  let (:poa_filename) { 'lsi_purchase_order_acknowledgment_sample.txt' }
  let (:poa_file_content) { File.read(Rails.root.join('spec', 'fixtures', 'files', poa_filename)) }
  let (:poa_remote_filename) { 'M030112304.PPR' }

  let (:asn_filename) { 'lsi_advanced_shipping_notification_sample.txt' }
  let (:asn_file_content) { File.read(Rails.root.join('spec', 'fixtures', 'files', asn_filename)) }
  let (:asn_remote_filename) { 'M030212304.PBS' }

  let (:ftp) { double('ftp') }
  before(:each) do
    expect(Net::FTP).to receive(:open).and_yield ftp
    expect(ftp).to receive(:chdir).with('outgoing')
    expect(ftp).to receive(:list).and_return [poa_remote_filename, asn_remote_filename]
    expect(ftp).to receive(:gettextfile).with(poa_remote_filename).and_return(poa_file_content)
    expect(ftp).to receive(:gettextfile).with(asn_remote_filename).and_return(asn_file_content)
    allow(ftp).to receive(:delete)
  end

  describe '::perform' do
    it 'calls the Lsi::PoaProcessor::process method' do
      expect_any_instance_of(Lsi::PoaProcessor).to \
        receive(:process)
      UpdateImportProcessor.perform
    end

    it 'saves the file content to the database' do
      expect do
        UpdateImportProcessor.perform
      end.to change(Document, :count).by(2)
    end

    it 'deletes the remote file' do
      expect(ftp).to receive(:delete).with(poa_remote_filename)
      expect(ftp).to receive(:delete).with(asn_remote_filename)
      UpdateImportProcessor.perform
    end
  end
end
