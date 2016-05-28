require 'rails_helper'

describe OrderImportProcessor do
  let!(:client) { FactoryGirl.create(:client, abbreviation: '3dm') }
  let (:ftp) { double('ftp') }
  before(:each) do
    allow(Net::FTP).to receive(:open).and_yield(ftp)
    allow(ftp).to receive(:delete)
  end

  describe '::perform' do
    it 'reads files from the FTP server' do
      expect(ftp).to receive(:chdir).with('3dm')
      expect(ftp).to receive(:list).and_return([])
      OrderImportProcessor.perform
    end

    context 'when 3DM orders are present' do
      let (:filename) { 'order20160302.csv' }
      let (:file_content) { File.read(Rails.root.join('spec', 'fixtures', 'files', '3dm_orders.csv')) }
      before(:each) do
        allow(ftp).to receive(:chdir)
        allow(ftp).to receive(:list).and_return([filename])
        allow(ftp).to receive(:gettextfile).with(filename).and_return(file_content)
      end

      it 'passes 3DM files to the 3DM order processor' do
        expect(ThreeDM::OrderImporter).to \
          receive(:new).
            with(file_content, client).
            and_call_original
        expect_any_instance_of(ThreeDM::OrderImporter).to receive(:process)
        OrderImportProcessor.perform
      end

      it 'deletes the file from the FTP server' do
        expect(ftp).to receive(:delete).with(filename)
        OrderImportProcessor.perform
      end
    end
  end
end
