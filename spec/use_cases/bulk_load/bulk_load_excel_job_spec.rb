require 'rails_helper'
require 'use_cases/bulk_load/bulk_load_excel_job'

describe 'UseCases::BulkLoad::ExcelDataAccessHelpers' do
    include_context 'a mock bulk load context'

    include UseCases::BulkLoad::ExcelDataAccessHelpers

    let(:spreadsheet_workbook_mock) {double('spreadsheet_workbook')}
    let(:first_row_index) {0}
    let(:last_row_index) {3}

    before :each do
        context.spreadsheet_workbook = spreadsheet_workbook_mock
        allow(spreadsheet_workbook_mock).to receive(:first_row) {first_row_index}
        allow(spreadsheet_workbook_mock).to receive(:last_row) {last_row_index}
    end

    describe '#get_first_row_index' do
        it 'returns the index of the first_row' do
            actual = get_first_row_index(context)
            expect(actual).to eq first_row_index
        end
    end

    describe '#get_last_row_index' do
        it 'returns the index of the last_row' do
            actual = get_last_row_index(context)
            expect(actual).to eq last_row_index
        end
    end

    describe '#get_value_for_cell' do
        let(:contents_mock) {'Cell Contents'}

        let(:row_index) {1}
        let(:column_index) {3}

        actual = nil

        before :each do
            allow(spreadsheet_workbook_mock).to receive(:cell) {contents_mock}
            actual = get_value_for_cell(row_index, column_index, context)
        end

        it 'invokes the spreadsheet #cell function' do
            expect(spreadsheet_workbook_mock).to have_received(:cell).with(row_index,
                                                                           column_index)
        end

        it 'returns the content of the cell' do
            expect(actual).to eq contents_mock
        end
    end

end
