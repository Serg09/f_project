require 'rails_helper'

describe OrderImportProcessor do
  let!(:client) do
    FactoryGirl.create(:client, abbreviation: '3dm',
                                order_import_processor_class: 'ThreeDM::OrderImporter')
  end
  let (:ftp) { double('ftp') }

  describe '::perform' do
    it 'reads files from the FTP server' do
      expect(ORDER_IMPORT_FILE_PROVIDER).to receive(:get_and_delete_files)
      OrderImportProcessor.perform
    end

    context 'when 3DM orders are present' do
      let (:filename) { 'order20160302.csv' }
      let (:file_content) { File.read(Rails.root.join('spec', 'fixtures', 'files', '3dm_orders.csv')) }
      let (:file_lines) { file_content.lines }
      before(:each) do
        allow(ORDER_IMPORT_FILE_PROVIDER).to \
          receive(:get_and_delete_files).
          with('3dm').
          and_yield(file_lines.take(2).join(""), filename)
      end

      it 'passes 3DM files to the 3DM order processor' do
        expect(ThreeDM::OrderImporter).to \
          receive(:new).
          with(file_lines.take(2).join(""), client).
          and_call_original
        expect_any_instance_of(ThreeDM::OrderImporter).to receive(:process)
        OrderImportProcessor.perform
      end
    end
  end
end
