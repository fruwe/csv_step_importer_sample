class CreateBookAuthors < ActiveRecord::Migration[5.1]
  def change
    create_table :book_authors do |t|
      t.references :book, null: false
      t.references :author, null: false
      t.timestamps
    end
    add_index :book_authors, [:book_id, :author_id], unique: true
  end
end
