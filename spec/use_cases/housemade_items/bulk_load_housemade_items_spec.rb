require 'rails_helper'
require 'use_cases/bulk_load/bulk_load_job'
require 'use_cases/housemade_items/bulk_load_housemade_items'

shared_context 'housemade item bulk load' do
    include_context 'a mock bulk load context'
    include_context 'core domain model for housemade items'

    let(:row_index) {0}

    let(:item_name) {'Herb Mix'}
    let(:item_unit) {service_provider_unit_bag}
    let(:restaurant_identifier) {'Seasonal Herbs'}
    let(:item_description) {'Seasonal Herb Chopped and Mixed'}
    let(:recipe_cost_per_unit) {'4.56'}
    let(:recipe_cost_date) {Date.today}

    let(:rows_mock) {
        [
            [
                item_name,
                item_unit.name,
                restaurant_identifier,
                item_description,
                accounting_category.name,
                recipe_cost_per_unit,
                recipe_cost_date
            ]
        ]
    }

    before :each do
        allow(command).to receive(:get_value_for_cell).and_call_original

        context.rows = rows_mock
    end
end

describe 'UseCases::HousemadeItems::VerifyHousemadeItemsDataHelper' do
    include_context 'housemade item bulk load'

    class VerifyHousemadeItemsCommandMock < UseCases::BulkLoad::VerifyDataCommand
        include UseCases::HousemadeItems::VerifyHousemadeItemsDataHelper

        def get_value_for_cell(row_index, column_index, context)
            row = context.rows[row_index]
            row[column_index-1]
        end
    end

    let(:command) {VerifyHousemadeItemsCommandMock.new}

    describe '#verify_row' do
        include_context 'verify command helper method mocks'

        before :each do
            command.verify_row(row_index, context)
        end

        context 'individual columns:' do
            context 'Item name' do
                let(:column_index) {VerifyHousemadeItemsCommandMock::ITEM_NAME_COLUMN}

                it_behaves_like 'an accessed value'
                it_behaves_like 'a required value'
            end

            context 'Item unit' do
                let(:column_index) {VerifyHousemadeItemsCommandMock::ITEM_UNIT_COLUMN}

                it_behaves_like 'an accessed value'
                it_behaves_like 'a required value'
            end

            context 'Restaurant identifier' do
                let(:column_index) {VerifyHousemadeItemsCommandMock::REST_ITEM_ID_COLUMN}

                it_behaves_like 'an accessed value'
                it_behaves_like 'an optional value'
            end

            context 'Item description' do
                let(:column_index) {VerifyHousemadeItemsCommandMock::ITEM_DESC_COLUMN}

                it_behaves_like 'an accessed value'
                it_behaves_like 'an optional value'
            end

            context 'Accounting category' do
                let(:column_index) {VerifyHousemadeItemsCommandMock::ACCT_CATEGORY_COLUMN}

                it_behaves_like 'an accessed value'
                it_behaves_like 'a required value'
                it_behaves_like 'a check for an existing record: accounting_category, by name'
            end

            context 'Recipe cost per unit' do
                let(:column_index) {VerifyHousemadeItemsCommandMock::RECIPE_COST_COLUMN}

                it_behaves_like 'an accessed value'
                it_behaves_like 'an optional value'
                it_behaves_like 'a type-restricted value: decimal'
            end

            context 'Recipe cost date' do
                let(:column_index) {VerifyHousemadeItemsCommandMock::RECIPE_DATE_COLUMN}

                it_behaves_like 'an accessed value'
                it_behaves_like 'an optional value'
                it_behaves_like 'a type-restricted value: date'
            end
        end
    end
end

describe 'UseCases::HousemadeItems::LoadHousemadeItemsDataHelper' do
    include_context 'housemade item bulk load'

    class LoadHousemadeItemsCommandMock < UseCases::BulkLoad::LoadDataCommand
        include UseCases::HousemadeItems::LoadHousemadeItemsDataHelper

        def get_value_for_cell(row_index, column_index, context)
            row = context.rows[row_index]
            row[column_index-1]
        end
    end

    let(:command) {LoadHousemadeItemsCommandMock.new}

    describe '#process_row' do
        include_context 'load command helper method mocks'

        before :each do
            command.process_row(row_index, context)
        end

        context 'individual columns:' do
            context 'Item name' do
                let(:column_index) {LoadHousemadeItemsCommandMock::ITEM_NAME_COLUMN}

                it_behaves_like 'an accessed value'
            end

            context 'Item unit' do
                let(:column_index) {LoadHousemadeItemsCommandMock::ITEM_UNIT_COLUMN}

                it_behaves_like 'an accessed value'
            end

            context 'Restaurant identifier' do
                let(:column_index) {LoadHousemadeItemsCommandMock::REST_ITEM_ID_COLUMN}

                it_behaves_like 'an accessed value'
            end

            context 'Item description' do
                let(:column_index) {LoadHousemadeItemsCommandMock::ITEM_DESC_COLUMN}

                it_behaves_like 'an accessed value'
            end

            context 'Accounting category' do
                let(:column_index) {LoadHousemadeItemsCommandMock::ACCT_CATEGORY_COLUMN}

                it_behaves_like 'an accessed value'
            end

            context 'Recipe cost per unit' do
                let(:column_index) {LoadHousemadeItemsCommandMock::RECIPE_COST_COLUMN}

                it_behaves_like 'an accessed value'
            end

            context 'Recipe cost date' do
                let(:column_index) {LoadHousemadeItemsCommandMock::RECIPE_DATE_COLUMN}

                it_behaves_like 'an accessed value'
            end
        end

        context 'type conversions' do
            it 'interprets :recipe_cost_date as a Date' do
                expect(command).to have_received(:coerce_to_date).with(recipe_cost_date)
            end
        end

        context 'loaded records:' do
            context 'accounting_category' do
                it 'calls #get_accounting_category_by_name' do
                    expect(command).to have_received(:get_accounting_category_by_name).with(accounting_category.name, context)
                end
            end

            context 'item_unit' do
                it 'calls #get_service_provider_unit_by_unit_name' do
                    expect(command).to have_received(:get_service_provider_unit_by_unit_name).with(item_unit.name, context)
                end
            end
        end

        context 'the new item' do
            housemade_item = nil

            before :each do
                housemade_item = HousemadeItem.last
            end

            it 'has the correct value for :name' do
                expect(housemade_item.name).to eq item_name
            end

            it 'has the correct value for :item_unit' do
                expect(housemade_item.item_unit).to eq item_unit
            end

            it 'has the correct value for :restaurant_identifier' do
                expect(housemade_item.restaurant_identifier).to eq restaurant_identifier
            end

            it 'has the correct value for :description' do
                expect(housemade_item.description).to eq item_description
            end

            it 'has the correct value for :accounting_category' do
                expect(housemade_item.accounting_category).to eq accounting_category
            end

            it 'has the correct value for :recipe_cost_per_unit' do
                expect(housemade_item.recipe_cost_per_unit).to eq recipe_cost_per_unit.to_d
            end

            it 'has the correct value for :recipe_cost_timestamp' do
                recipe_cost_timestamp = restaurant.beginning_of_day_local(recipe_cost_date)
                expect(housemade_item.recipe_cost_timestamp).to eq recipe_cost_timestamp
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

        describe 'when the item already exists' do
            before :each do
                bulk_load_inventory_items_job.added_items_count = 0
                bulk_load_inventory_items_job.skipped_items_count = 0

                # Note: Attempt to reload the same item data.
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

        describe 'when the item :description is blank' do
            before :each do
                rows_mock[0][LoadHousemadeItemsCommandMock::ITEM_NAME_COLUMN - 1] = 'Housemade-No Desc'
                rows_mock[0][LoadHousemadeItemsCommandMock::ITEM_DESC_COLUMN - 1] = nil

                command.process_row(row_index, context)
            end

            context 'the new item' do
                housemade_item = nil

                before :each do
                    housemade_item = HousemadeItem.last
                end

                it 'fills :description with an empty string' do
                    expect(housemade_item.description).to eq ''
                end
            end
        end

        describe 'when the :recipe_cost_per_unit is blank' do
            before :each do
                rows_mock[0][LoadHousemadeItemsCommandMock::ITEM_NAME_COLUMN - 1] = 'Housemade-No Cost'
                rows_mock[0][LoadHousemadeItemsCommandMock::RECIPE_COST_COLUMN - 1] = nil

                command.process_row(row_index, context)
            end

            context 'the new item' do
                housemade_item = nil

                before :each do
                    housemade_item = HousemadeItem.last
                end

                it 'fills :recipe_cost_per_unit with zero' do
                    expect(housemade_item.recipe_cost_per_unit).to eq 0
                end
            end
        end

        describe 'when the :recipe_cost_date is blank' do
            before :each do
                rows_mock[0][LoadHousemadeItemsCommandMock::ITEM_NAME_COLUMN - 1] = 'Housemade-No Date'
                rows_mock[0][LoadHousemadeItemsCommandMock::RECIPE_DATE_COLUMN - 1] = nil

                command.process_row(row_index, context)
            end

            context 'the new item' do
                housemade_item = nil

                before :each do
                    housemade_item = HousemadeItem.last
                end

                it 'leaves :recipe_cost_timestamp as nil' do
                    expect(housemade_item.recipe_cost_timestamp).to be_nil
                end
            end
        end
    end
end
