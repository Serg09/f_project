class CreateDocuments < ActiveRecord::Migration
  def change
    create_table :documents do |t|
      t.string :source
      t.string :filename
      t.text :content

      t.timestamps null: false
    end
  end
end
