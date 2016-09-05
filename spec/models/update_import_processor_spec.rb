require 'rails_helper'

describe UpdateImportProcessor do
  let (:poa_filename) { 'lsi_purchase_order_acknowledgment_sample.txt' }
  let (:poa_file_content) { File.read(Rails.root.join('spec', 'fixtures', 'files', poa_filename)) }
  let (:poa_lines) { poa_file_content.lines }
  let (:poa_remote_filename) { 'M030112304.PPR' }

  let (:asn_filename) { 'lsi_advanced_shipping_notification_sample.txt' }
  let (:asn_file_content) { File.read(Rails.root.join('spec', 'fixtures', 'files', asn_filename)) }
  let (:asn_lines) { asn_file_content.lines }
  let (:asn_remote_filename) { 'M030212304.PBS' }

  before(:each) do
    expect(REMOTE_FILE_PROVIDER).to \
      receive(:get_and_delete_files).
      with('outgoing').
      and_yield(poa_file_content, poa_remote_filename).
      and_yield(asn_file_content, asn_remote_filename)
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
  end
end
