# == Schema Information
#
# Table name: book_authors
#
#  id         :bigint(8)        not null, primary key
#  book_id    :bigint(8)        not null
#  author_id  :bigint(8)        not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# CSV_PATH = 'spec/fixtures/files/books.csv'
# PROCESSORS = [BookAuthor::ImportableModel]
# CSVStepImporter::Loader.new(path: CSV_PATH, processor_classes: PROCESSORS).save

class BookAuthor < ApplicationRecord
  belongs_to :author, inverse_of: :book_authors
  belongs_to :book, inverse_of: :book_authors

  class ImportableModel < CSVStepImporter::Model::ImportableModel
    def model_class
      Module.nesting[1]
    end

    def dao_class
      ::BookAuthor::DAO
    end

    def columns
      model_class.column_names.map(&:to_sym) - [:id]
    end

    def on_duplicate_key_update
      [:updated_at]
    end
  end

  class DAO < CSVStepImporter::Model::DAO
    def author_id
      dao_for(model: Author::ImportableModel).id
    end

    def book_id
      dao_for(model: Book::ImportableModel).id
    end
  end
end
