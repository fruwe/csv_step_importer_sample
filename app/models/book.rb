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
  belongs_to :author

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

    def finder_keys
      [:isbn]
    end

    # Skip a book which appear more than once in the CSV
    def build_daos_for_row(row)
      cache[:uniq_books] ||= []

      unless cache[:uniq_books].include?(row.attributes[:isbn])
        cache[:uniq_books] << row.attributes[:isbn]
        dao_class.new parent: dao_node, row: row
      end
    end
  end
end
