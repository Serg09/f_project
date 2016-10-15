class AddAuthTokenToClients < ActiveRecord::Migration
  def up
    add_column :clients, :auth_token, :string, limit: 40
    add_index :clients, :auth_token, unique: true

    Client.all.each do |c|
      c.update_attribute :auth_token, SecureRandom.uuid.gsub('-', '')
    end

    change_column :clients, :auth_token, :string, limit: 40, null: false
  end

  def down
    remove_column :clients, :auth_token
  end
end
