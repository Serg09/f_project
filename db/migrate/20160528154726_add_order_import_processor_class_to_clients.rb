class AddOrderImportProcessorClassToClients < ActiveRecord::Migration
  def change
    add_column :clients, :order_import_processor_class, :string, limit: 250
  end
end
