# == Schema Information
#
# Table name: authors
#
#  id         :bigint(8)        not null, primary key
#  name       :string(255)      not null
#  email      :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# CSV_PATH = 'spec/fixtures/files/books.csv'
# PROCESSORS = [Author::ImportableModel]
# CSVStepImporter::Loader.new(path: CSV_PATH, processor_classes: PROCESSORS).save
class Author < ApplicationRecord
  class ImportableModel < CSVStepImporter::Model::ImportableModel
    def model_class
      Module.nesting[1]
    end

    def columns
      model_class.column_names.map(&:to_sym) - [:id]
    end

    def on_duplicate_key_update
      [:updated_at]
    end

    def dao_class
      ::Author::DAO
    end

    def reflector_class
      CSVStepImporter::Model::Reflector
    end

    def finder_keys
      [:name]
    end

    # def on_duplicate_key_ignore
    #   # true
    #   false
    # end

    # Skip an author who appear more than once in the CSV
    def build_daos_for_row(row)
      cache[:unique_authors] ||= []

      unless cache[:unique_authors].include?(row.attributes[:author])
        cache[:unique_authors] << row.attributes[:author]
        dao_class.new parent: dao_node, row: row
      end
    end
  end

  class DAO < CSVStepImporter::Model::DAO
    def name
      value_for_key :author
    end
  end
end
