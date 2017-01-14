require 'rails_helper'
require 'net/ftp'

describe ExportProcessor do

  context 'when unbatched orders are present' do
    let (:ftp) { double('ftp') }
    let (:physical_product) { FactoryGirl.create :product }
    let (:electronic_product) { FactoryGirl.create :electronic_product }
    let!(:order1) do
      FactoryGirl.create :submitted_order,
        delivery_email: Faker::Internet.email,
        item_attributes: [
          {sku: physical_product.sku},
          {sku: electronic_product.sku}
        ]
    end

    describe '#perform' do
      context 'on success' do
        before(:each) do
          allow(ftp).to receive(:chdir)
          allow(ftp).to receive(:puttextcontent)
        end

        it 'creates an order batch' do
          expect do
            ExportProcessor.perform
          end.to change(Batch, :count).by(1)
        end

        it 'uploads the order batch to the destination in the "incoming" folder' do
          expect(REMOTE_FILE_PROVIDER).to receive(:send_file) do |file, remotefile, folder|
            expect(remotefile).to eq 'PPO.M03021230'
            expect(folder).to eq 'incoming'
          end
          Timecop.freeze(DateTime.parse('2016-03-02 06:30:42 CST')) do
            ExportProcessor.perform
          end
        end

        it 'sets the batch status to "delivered"' do
          ExportProcessor.perform
          batch = Batch.last
          expect(batch.status).to eq Batch.DELIVERED
        end

        it 'includes the physical fulfillment items' do
          expect(REMOTE_FILE_PROVIDER).to receive(:send_file) do |file, remotefile, folder|
            expect(file.read).to include_sku physical_product
          end
          ExportProcessor.perform
        end

        it 'omits elecront fulfillment items' do
          expect(REMOTE_FILE_PROVIDER).to receive(:send_file) do |file, remotefile, folder|
            expect(file.read).not_to include_sku electronic_product
          end
          ExportProcessor.perform
        end
      end

      context 'on failure' do
        before(:each) do
          allow(REMOTE_FILE_PROVIDER).to receive(:send_file).and_raise(Net::FTPPermError)
        end

        it 'does not update the batch status' do
          ExportProcessor.perform
          batch = Batch.last
          expect(batch.status).to eq Batch.NEW
        end
      end
    end
  end

  context 'when no unbatched orders are present' do
    let (:batch) { FactoryGirl.create(:batch) }
    let!(:order) { FactoryGirl.create(:submitted_order, batch: batch) }

    describe '#perform' do
      it 'does not create a batch record' do
        expect do
          ExportProcessor.perform
        end.not_to change(Batch, :count)
      end

      it 'does not send FTP commands' do
        expect_any_instance_of(Net::FTP).not_to receive(:login)
        ExportProcessor.perform
      end
    end
  end
end
