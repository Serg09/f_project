require 'rails_helper'

describe UpdateImportProcessor do
  let (:filename) { 'lsi_purchase_order_acknowledgment_sample.txt' }
  let (:file_content) { File.read(Rails.root.join('spec', 'fixtures', 'files', filename)) }
  let (:remote_filename) { 'M030112304.PPR' }

  let (:ftp) { double('ftp') }
  before(:each) do
    expect(Net::FTP).to receive(:open).and_yield ftp
    expect(ftp).to receive(:chdir).with('outgoing')
    expect(ftp).to receive(:list).and_return [remote_filename]
    expect(ftp).to receive(:gettextfile).and_return(file_content)
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
      end.to change(Document, :count).by(1)
    end

    it 'deletes the remote file' do
      expect(ftp).to receive(:delete).with(remote_filename)
      UpdateImportProcessor.perform
    end
  end
end
