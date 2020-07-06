require 'rails_helper'
require 'use_cases/bulk_load/bulk_load_csv_job'

describe 'UseCases::BulkLoad::CsvDataAccessHelpers' do
    include_context 'a mock bulk load context'

    include UseCases::BulkLoad::CsvDataAccessHelpers

    let(:csv_array_mock) {
        [
            ['H1', 'H2'],
            ['11', '12'],
            ['21', '22']
        ]
    }

    before :each do
        context.csv_data_array = csv_array_mock
    end

    describe '#get_first_row_index' do
        it 'returns the index of the first_row' do
            actual = get_first_row_index(context)
            expect(actual).to eq 1
        end
    end

    describe '#get_last_row_index' do
        it 'returns the index of the last_row' do
            actual = get_last_row_index(context)
            expect(actual).to eq csv_array_mock.length
        end
    end

    describe '#get_value_for_cell' do
        let(:row_index) {2}
        let(:column_index) {2}

        actual = nil

        before :each do
            actual = get_value_for_cell(row_index, column_index, context)
        end

        it 'returns the content of the cell' do
            # NOTE: row_index and column_index start at 1
            expect(actual).to eq '12'
        end
    end

end
