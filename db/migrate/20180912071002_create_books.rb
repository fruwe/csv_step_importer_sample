class CreateBooks < ActiveRecord::Migration[5.1]
  def change
    create_table :books do |t|
      t.bigint :isbn, null: false
      t.string :title, null: false
      t.timestamps
    end
    add_index :books, :isbn, unique: true
  end
end
