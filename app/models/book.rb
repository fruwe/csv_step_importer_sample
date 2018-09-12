# == Schema Information
#
# Table name: books
#
#  id         :bigint(8)        not null, primary key
#  isbn       :bigint(8)        not null
#  title      :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# CSV_PATH = 'spec/fixtures/files/books.csv'
# PROCESSORS = [Book::ImportableModel]
# CSVStepImporter::Loader.new(path: CSV_PATH, processor_classes: PROCESSORS).save
class Book < ApplicationRecord
  has_many :book_authors, inverse_of: :book
  has_many :authors, through: :book_authors

  class ImportableModel < CSVStepImporter::Model::ImportableModel
    def model_class
      Module.nesting[1]
    end

    def columns
      model_class.column_names.map(&:to_sym) - [:id]
    end

    def on_duplicate_key_update
      [:title, :updated_at]
    end

    def reflector_class
      CSVStepImporter::Model::Reflector
    end

    def composite_key_columns
      [:isbn]
    end
  end
end
