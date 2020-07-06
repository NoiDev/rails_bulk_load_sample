require 'rails_helper'
require 'use_cases/purchase_items/bulk_load_beginning_costs'

shared_context 'beginning costs bulk load' do
    include_context 'a mock bulk load context'
    include_context 'three taxable inventory items'

    let(:inventory_item) {first_taxable_inventory_item}

    let(:row_index) {0}
    let(:beginning_inventory_cost) { '1.23' }

    let(:rows_mock) {
        [
            [
                inventory_item.id,
                inventory_item.name,
                inventory_item.item_unit.name,
                inventory_item.restaurant_identifier,
                inventory_item.description,
                beginning_inventory_cost
            ]
        ]
    }

    before :each do
        allow(command).to receive(:get_value_for_cell).and_call_original

        context.rows = rows_mock
    end
end

describe 'UseCases::PurchaseItems::VerifyBeginningCostsDataHelper' do
    include_context 'beginning costs bulk load'

    class VerifyBeginningInventoryCommandMock < UseCases::BulkLoad::VerifyDataCommand
        include UseCases::PurchaseItems::VerifyBeginningCostsDataHelper

        def get_value_for_cell(row_index, column_index, context)
            row = context.rows[row_index]
            row[column_index-1]
        end
    end

    let(:command) {VerifyBeginningInventoryCommandMock.new}

    describe '#verify_row' do
        include_context 'verify command helper method mocks'

        before :each do
            command.verify_row(row_index, context)
        end

        context 'individual columns:' do
            context 'Purchase item id' do
                let(:column_index) {VerifyBeginningInventoryCommandMock::ITEM_ID_COLUMN}
                let(:parameter_value) {inventory_item.id}

                it_behaves_like 'an accessed value'
                it_behaves_like 'a required value'
                it_behaves_like 'a type-restricted value: integer'
                it_behaves_like 'a check for an existing record: inventory_item, by id'
            end

            context 'Item name' do
                let(:column_index) {VerifyBeginningInventoryCommandMock::ITEM_NAME_COLUMN}

                it_behaves_like 'an ignored value'
            end

            context 'Item unit' do
                let(:column_index) {VerifyBeginningInventoryCommandMock::ITEM_UNIT_COLUMN}
                let(:parameter_value) {inventory_item.item_unit.name}

                it_behaves_like 'an accessed value'
                it_behaves_like 'a required value'
                it_behaves_like 'a check for an existing record: service_provider_unit, by unit_name'
            end

            context 'Restaurant identifier' do
                let(:column_index) {VerifyBeginningInventoryCommandMock::REST_ITEM_ID_COLUMN}

                it_behaves_like 'an ignored value'
            end

            context 'Item description' do
                let(:column_index) {VerifyBeginningInventoryCommandMock::ITEM_DESC_COLUMN}

                it_behaves_like 'an ignored value'
            end

            context 'Beginning cost' do
                let(:column_index) {VerifyBeginningInventoryCommandMock::BEGINNING_COST_COLUMN}
                let(:parameter_value) {beginning_inventory_cost}

                it_behaves_like 'an accessed value'
                it_behaves_like 'a required value'
                it_behaves_like 'a type-restricted value: decimal'
                it_behaves_like 'a value-restricted quantity: non-negative'
            end
        end
    end
end

describe UseCases::PurchaseItems::LoadBeginningCostsDataHelper do
    include_context 'beginning costs bulk load'

    class LoadBeginningInventoryCommandMock < UseCases::BulkLoad::LoadDataCommand
        include UseCases::PurchaseItems::LoadBeginningCostsDataHelper

        def get_value_for_cell(row_index, column_index, context)
            row = context.rows[row_index]
            row[column_index-1]
        end
    end

    let(:command) {LoadBeginningInventoryCommandMock.new}

    describe '#process_row' do
        include_context 'load command helper method mocks'

        before :each do
            command.process_row(row_index, context)
        end

        context 'individual columns:' do
            context 'Purchase item id' do
                let(:column_index) {LoadBeginningInventoryCommandMock::ITEM_ID_COLUMN}

                it_behaves_like 'an accessed value'
            end

            context 'Item name' do
                let(:column_index) {LoadBeginningInventoryCommandMock::ITEM_NAME_COLUMN}

                it_behaves_like 'an ignored value'
            end

            context 'Item unit' do
                let(:column_index) {LoadBeginningInventoryCommandMock::ITEM_UNIT_COLUMN}

                it_behaves_like 'an ignored value'
            end

            context 'Restaurant identifier' do
                let(:column_index) {LoadBeginningInventoryCommandMock::REST_ITEM_ID_COLUMN}

                it_behaves_like 'an ignored value'
            end

            context 'Item description' do
                let(:column_index) {LoadBeginningInventoryCommandMock::ITEM_DESC_COLUMN}

                it_behaves_like 'an ignored value'
            end

            context 'Beginning cost' do
                let(:column_index) {LoadBeginningInventoryCommandMock::BEGINNING_COST_COLUMN}

                it_behaves_like 'an accessed value'
            end
        end

        context 'loaded records:' do
            context 'inventory_item' do
                it 'calls #get_inventory_item_by_id' do
                    expect(command).to have_received(:get_inventory_item_by_id).with(inventory_item.id, context)
                end
            end
        end

        context 'the updated item' do
            before :each do
                inventory_item.reload
            end

            it 'has the new value for :starting_average_cost' do
                expect(inventory_item.starting_average_cost).to eq beginning_inventory_cost.to_d
            end
        end

        context 'the item counts' do
            it 'increments :added_items_count' do
                expect(bulk_load_inventory_items_job.added_items_count).to eq 1
            end

            it 'does NOT increment :skipped_items_count' do
                expect(bulk_load_inventory_items_job.skipped_items_count).to eq 0
            end
        end

        describe 'when the item cannot be found' do
            before :each do
                bulk_load_inventory_items_job.added_items_count = 0
                bulk_load_inventory_items_job.skipped_items_count = 0

                allow(command).to receive(:get_inventory_item_by_id) {nil}

                command.process_row(row_index, context)
            end

            context 'the item counts' do
                it 'does NOT increment :added_items_count' do
                    expect(bulk_load_inventory_items_job.added_items_count).to eq 0
                end

                it 'increments :skipped_items_count' do
                    expect(bulk_load_inventory_items_job.skipped_items_count).to eq 1
                end
            end
        end
    end
end
