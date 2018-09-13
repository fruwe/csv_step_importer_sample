# frozen_string_literal: true

require 'rails_helper'

# TODO: Please move this file somewhere
RSpec.describe 'ImporterSpec' do
  let(:csv_file) { 'spec/fixtures/files/books.csv' }
  let(:csv_options) {
    {
      file_encoding: Encoding::UTF_8,
    }
  }
  let(:csv_step_importer) {
    CSVStepImporter::Loader.new(
      path: csv_file,
      processor_classes: processor_classes,
      csv_options: csv_options
    )
  }
  let(:processor_classes) {[
    Author::ImportableModel,
    Book::ImportableModel,
    BookAuthor::ImportableModel,
  ]}

  it 'it should load a CSV' do
    ActiveRecord::Base.logger = Logger.new STDOUT
    csv_step_importer.save!

    expect(Author.count).to eq 2
    expect(Book.count).to eq 3
    expect(BookAuthor.count).to eq 4

    expect(Author.find_by(name: 'Chris Fruwe').books.collect(&:isbn)).to eq [9902392834829, 9923082349230]
    expect(Author.find_by(name: 'Cong Vo').books.collect(&:isbn)).to eq [9928402821839, 9923082349230]
  end
end
