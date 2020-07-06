require 'rails_helper'
require 'use_cases/bulk_load/bulk_load_job'
require 'use_cases/purchase_items/bulk_load_purchase_items'

shared_context 'inventory item bulk load' do
    include_context 'a mock bulk load context'
    include_context 'core domain model for vendor inventory items'

    let(:row_index) {0}

    let(:item_name) {'Whole Milk'}
    let(:item_unit) {service_provider_unit_bottle}
    let(:restaurant_identifier) {'Milk'}
    let(:item_description) {'6 Bottles per case'}
    let(:taxable) {true}
    let(:ordering) {true}
    let(:inventory) {true}
    let(:starting_average_cost) {'3.68'}
    let(:primary_vendor) {true}
    let(:vendor_specific_identifier) {'WhlMilk'}
    let(:order_unit) {service_provider_unit_case}
    let(:pack_value) {6.0}

    let(:rows_mock) {
        [
            [
                item_name,
                item_unit.name,
                restaurant_identifier,
                item_description,
                accounting_category.name,
                taxable,
                ordering,
                inventory,
                starting_average_cost,
                primary_vendor,
                vendor.key,
                vendor_specific_identifier,
                order_unit.name,
                pack_value
            ]
        ]
    }

    before :each do
        allow(command).to receive(:get_value_for_cell).and_call_original

        context.rows = rows_mock
    end
end

describe 'UseCases::PurchaseItems::VerifyPurchaseItemsDataHelper' do
    include_context 'inventory item bulk load'

    class VerifyPurchaseItemsCommandMock < UseCases::BulkLoad::VerifyDataCommand
        include UseCases::PurchaseItems::VerifyPurchaseItemsDataHelper

        def get_value_for_cell(row_index, column_index, context)
            row = context.rows[row_index]
            row[column_index-1]
        end
    end

    let(:command) {VerifyPurchaseItemsCommandMock.new}

    describe '#verify_row' do
        include_context 'verify command helper method mocks'

        before :each do
            allow(command).to receive(:log_new_ordering_inventory_item)
            allow(command).to receive(:log_primary_vendor_for_new_ordering_inventory_item)
            command.verify_row(row_index, context)
        end

        context 'when the item is used for ordering' do
            context 'individual columns:' do
                context 'Item name' do
                    let(:column_index) {VerifyPurchaseItemsCommandMock::ITEM_NAME_COLUMN}

                    it_behaves_like 'an accessed value'
                    it_behaves_like 'a required value'
                end

                context 'Item unit' do
                    let(:column_index) {VerifyPurchaseItemsCommandMock::ITEM_UNIT_COLUMN}

                    it_behaves_like 'an accessed value'
                    it_behaves_like 'a required value'
                    it_behaves_like 'a check for an existing record: service_provider_unit, by unit_name'
                end

                context 'Restaurant identifier' do
                    let(:column_index) {VerifyPurchaseItemsCommandMock::REST_ITEM_ID_COLUMN}

                    it_behaves_like 'an accessed value'
                    it_behaves_like 'an optional value'
                end

                context 'Item description' do
                    let(:column_index) {VerifyPurchaseItemsCommandMock::ITEM_DESC_COLUMN}

                    it_behaves_like 'an accessed value'
                    it_behaves_like 'an optional value'
                end

                context 'Accounting category' do
                    let(:column_index) {VerifyPurchaseItemsCommandMock::ACCT_CATEGORY_COLUMN}

                    it_behaves_like 'an accessed value'
                    it_behaves_like 'a required value'
                    it_behaves_like 'a check for an existing record: accounting_category, by name'
                end

                context 'Taxable' do
                    let(:column_index) {VerifyPurchaseItemsCommandMock::TAXABLE_COLUMN}

                    it_behaves_like 'an accessed value'
                    it_behaves_like 'a required value'
                    it_behaves_like 'a type-restricted value: boolean'
                end

                context 'Ordering' do
                    let(:column_index) {VerifyPurchaseItemsCommandMock::ORDERING_COLUMN}

                    it_behaves_like 'an accessed value'
                    it_behaves_like 'a required value'
                    it_behaves_like 'a type-restricted value: boolean'
                end

                context 'Inventory' do
                    let(:column_index) {VerifyPurchaseItemsCommandMock::INVENTORY_COLUMN}

                    it_behaves_like 'an accessed value'
                    it_behaves_like 'a required value'
                    it_behaves_like 'a type-restricted value: boolean'
                end

                context 'Begining inventory cost' do
                    let(:column_index) {VerifyPurchaseItemsCommandMock::BEGINNING_COST_COLUMN}

                    it_behaves_like 'an accessed value'
                    it_behaves_like 'an optional value'
                    it_behaves_like 'a type-restricted value: decimal'
                    it_behaves_like 'a value-restricted quantity: non-negative'
                end

                context 'Primary vendor flag' do
                    let(:column_index) {VerifyPurchaseItemsCommandMock::PRIMARY_VENDOR_COLUMN}

                    it_behaves_like 'an accessed value'
                    it_behaves_like 'a required value'
                    it_behaves_like 'a type-restricted value: boolean'
                end

                context 'Vendor key' do
                    let(:column_index) {VerifyPurchaseItemsCommandMock::VENDOR_KEY_COLUMN}

                    it_behaves_like 'an accessed value'
                    it_behaves_like 'a required value'
                    it_behaves_like 'a check for an existing record: vendor, by key'
                end

                context 'Vendor identifier' do
                    let(:column_index) {VerifyPurchaseItemsCommandMock::VENDOR_ITEM_ID_COLUMN}

                    it_behaves_like 'an accessed value'
                    it_behaves_like 'an optional value'
                end

                context 'Order unit' do
                    let(:column_index) {VerifyPurchaseItemsCommandMock::ORDER_UNIT_COLUMN}

                    it_behaves_like 'an accessed value'
                    it_behaves_like 'a required value'
                    it_behaves_like 'a check for an existing record: service_provider_unit, by unit_name'
                    it_behaves_like 'a check for an allowed_order_unit'
                end

                context 'Pack value' do
                    let(:column_index) {VerifyPurchaseItemsCommandMock::PACK_VALUE_COLUMN}

                    it_behaves_like 'an accessed value'
                    it_behaves_like 'a required value'
                    it_behaves_like 'a type-restricted value: decimal'
                end
            end
        end

        context 'when the item is NOT used for ordering' do
            let(:ordering) {false}
            let(:explanation) {'Item is not used for ordering.'}

            context 'individual columns:' do
                context 'Item name' do
                    let(:column_index) {VerifyPurchaseItemsCommandMock::ITEM_NAME_COLUMN}

                    it_behaves_like 'an accessed value'
                    it_behaves_like 'a required value'
                end

                context 'Item unit' do
                    let(:column_index) {VerifyPurchaseItemsCommandMock::ITEM_UNIT_COLUMN}

                    it_behaves_like 'an accessed value'
                    it_behaves_like 'a required value'
                    it_behaves_like 'a check for an existing record: service_provider_unit, by unit_name'
                end

                context 'Restaurant identifier' do
                    let(:column_index) {VerifyPurchaseItemsCommandMock::REST_ITEM_ID_COLUMN}

                    it_behaves_like 'an accessed value'
                    it_behaves_like 'an optional value'
                end

                context 'Item description' do
                    let(:column_index) {VerifyPurchaseItemsCommandMock::ITEM_DESC_COLUMN}

                    it_behaves_like 'an accessed value'
                    it_behaves_like 'an optional value'
                end

                context 'Accounting category' do
                    let(:column_index) {VerifyPurchaseItemsCommandMock::ACCT_CATEGORY_COLUMN}

                    it_behaves_like 'an accessed value'
                    it_behaves_like 'a required value'
                    it_behaves_like 'a check for an existing record: accounting_category, by name'
                end

                context 'Taxable' do
                    let(:column_index) {VerifyPurchaseItemsCommandMock::TAXABLE_COLUMN}

                    it_behaves_like 'an accessed value'
                    it_behaves_like 'a required value'
                    it_behaves_like 'a type-restricted value: boolean'
                end

                context 'Ordering' do
                    let(:column_index) {VerifyPurchaseItemsCommandMock::ORDERING_COLUMN}

                    it_behaves_like 'an accessed value'
                    it_behaves_like 'a required value'
                    it_behaves_like 'a type-restricted value: boolean'
                end

                context 'Inventory' do
                    let(:column_index) {VerifyPurchaseItemsCommandMock::INVENTORY_COLUMN}

                    it_behaves_like 'an accessed value'
                    it_behaves_like 'a required value'
                    it_behaves_like 'a type-restricted value: boolean'
                end

                context 'Begining inventory cost' do
                    let(:column_index) {VerifyPurchaseItemsCommandMock::BEGINNING_COST_COLUMN}

                    it_behaves_like 'an accessed value'
                    it_behaves_like 'an optional value'
                    it_behaves_like 'a type-restricted value: decimal'
                    it_behaves_like 'a value-restricted quantity: non-negative'
                end

                context 'Primary vendor flag' do
                    let(:column_index) {VerifyPurchaseItemsCommandMock::PRIMARY_VENDOR_COLUMN}

                    it_behaves_like 'an accessed value'
                    it_behaves_like 'a required blank cell'
                end

                context 'Vendor key' do
                    let(:column_index) {VerifyPurchaseItemsCommandMock::VENDOR_KEY_COLUMN}

                    it_behaves_like 'an accessed value'
                    it_behaves_like 'a required blank cell'
                end

                context 'Vendor identifier' do
                    let(:column_index) {VerifyPurchaseItemsCommandMock::VENDOR_ITEM_ID_COLUMN}

                    it_behaves_like 'an accessed value'
                    it_behaves_like 'a required blank cell'
                end

                context 'Order unit' do
                    let(:column_index) {VerifyPurchaseItemsCommandMock::ORDER_UNIT_COLUMN}

                    it_behaves_like 'an accessed value'
                    it_behaves_like 'a required blank cell'
                end

                context 'Pack value' do
                    let(:column_index) {VerifyPurchaseItemsCommandMock::PACK_VALUE_COLUMN}

                    it_behaves_like 'an accessed value'
                    it_behaves_like 'a required blank cell'
                end
            end
        end
    end

    describe '#before_verify_all_rows' do
        before :each do
            command.send(:before_verify_all_rows,
                         context)
        end

        it 'creates an empty hash for :primary_vendor data' do
            actual = command.instance_variable_get(:@inventory_item_primary_vendors)
            expected_hash = {}
            expect(actual).to eq expected_hash
        end
    end

    describe '#after_verify_all_rows' do
        before :each do
            allow(command).to receive(:each_new_ordering_inventory_item_must_have_a_primary_vendor)
            command.send(:after_verify_all_rows,
                         context)
        end

        it 'calls #each_new_ordering_inventory_item_must_have_a_primary_vendor' do
            expect(command).to have_received(:each_new_ordering_inventory_item_must_have_a_primary_vendor).with(context)
        end
    end

    describe '#log_new_ordering_inventory_item' do
        let(:inventory_item_name) {'Brocoli'}
        let(:row_index) {3}

        before :each do
            # Set up the data hash.
            command.send(:before_verify_all_rows,
                         context)
        end

        context 'when the item is called the first time' do
            before :each do
                command.send(:log_new_ordering_inventory_item,
                             inventory_item_name,
                             row_index)
            end

            it 'creates an entry for the inventory_item' do
                data_hash = command.instance_variable_get(:@inventory_item_primary_vendors)
                actual = data_hash[inventory_item_name]
                expected_entry = {
                    row_index: row_index,
                    primary_vendor_set: false
                }
                expect(actual).to eq expected_entry
            end
        end

        context 'when the item is called the subsequent times' do
            before :each do
                data_hash = command.instance_variable_get(:@inventory_item_primary_vendors)
                data_hash[inventory_item_name] = {
                    row_index: row_index - 1,
                    primary_vendor_set: true
                }

                command.send(:log_new_ordering_inventory_item,
                             inventory_item_name,
                             row_index)
            end

            it 'leaves the existing entry intact' do
                data_hash = command.instance_variable_get(:@inventory_item_primary_vendors)
                actual = data_hash[inventory_item_name]
                expected_entry = {
                    row_index: row_index - 1,
                    primary_vendor_set: true
                }
                expect(actual).to eq expected_entry
            end
        end
    end

    describe '#log_primary_vendor_for_new_ordering_inventory_item' do
        let(:inventory_item_name) {'Brocoli'}
        let(:row_index) {3}

        before :each do
            # Set up the data hash.
            command.send(:before_verify_all_rows,
                         context)
            command.send(:log_new_ordering_inventory_item,
                         inventory_item_name,
                         row_index)
            command.send(:log_primary_vendor_for_new_ordering_inventory_item,
                         inventory_item_name)
        end

        it 'sets :primary_vendor_set flag' do
            data_hash = command.instance_variable_get(:@inventory_item_primary_vendors)
            actual = data_hash[inventory_item_name][:primary_vendor_set]
            expect(actual).to be_truthy
        end
    end

    describe '#each_new_ordering_inventory_item_must_have_a_primary_vendor' do
        let(:inventory_item_name_1) {'Asparagus'}
        let(:inventory_item_name_2) {'Brocoli'}

        let(:row_index_1) {1}
        let(:row_index_2) {3}

        before :each do
            allow(command).to receive(:create_error)

            # Set up the data hash.
            command.send(:before_verify_all_rows,
                         context)
            command.send(:log_new_ordering_inventory_item,
                         inventory_item_name_1,
                         row_index_1)
            command.send(:log_new_ordering_inventory_item,
                         inventory_item_name_2,
                         row_index_2)
            command.send(:log_primary_vendor_for_new_ordering_inventory_item,
                         inventory_item_name_2)

            command.send(:each_new_ordering_inventory_item_must_have_a_primary_vendor,
                         context)
        end

        context 'when the registed item does NOT have a :primary_vendor' do
            it 'calls #create_error' do
                ORDERING_COLUMN = UseCases::PurchaseItems::PurchaseItemsColumns::ORDERING_COLUMN
                PRIMARY_VENDOR_COLUMN = UseCases::PurchaseItems::PurchaseItemsColumns::PRIMARY_VENDOR_COLUMN
                inventory_item_name = inventory_item_name_1
                row_index = row_index_1
                error_message = "New inventory item #{inventory_item_name.inspect} introduced on row ##{row_index_1} is flagged for Ordering (column ##{ORDERING_COLUMN}) but does not have a vendor flagged as Primary (column ##{PRIMARY_VENDOR_COLUMN})."
                expect(command).to have_received(:create_error).with(row_index,
                                                                     PRIMARY_VENDOR_COLUMN,
                                                                     error_message,
                                                                     context)
            end
        end

        context 'when the registed item has a :primary_vendor' do
            it 'does NOT call #create_error' do
                row_index = row_index_2
                expect(command).not_to have_received(:create_error).with(row_index,
                                                                         any_args)
            end
        end
    end
end

describe 'UseCases::PurchaseItems::LoadPurchaseItemsDataHelper' do
    include_context 'inventory item bulk load'

    class LoadPurchaseItemsCommandMock < UseCases::BulkLoad::LoadDataCommand
        include UseCases::PurchaseItems::LoadPurchaseItemsDataHelper

        def get_value_for_cell(row_index, column_index, context)
            row = context.rows[row_index]
            row[column_index-1]
        end
    end

    let(:command) {LoadPurchaseItemsCommandMock.new}

    describe '#process_row' do
        include_context 'load command helper method mocks'

        before :each do
            command.process_row(row_index, context)
        end

        context 'individual columns:' do
            context 'Item name' do
                let(:column_index) {LoadPurchaseItemsCommandMock::ITEM_NAME_COLUMN}

                it_behaves_like 'an accessed value'
            end

            context 'Item unit' do
                let(:column_index) {LoadPurchaseItemsCommandMock::ITEM_UNIT_COLUMN}

                it_behaves_like 'an accessed value'
            end

            context 'Restaurant identifier' do
                let(:column_index) {LoadPurchaseItemsCommandMock::REST_ITEM_ID_COLUMN}

                it_behaves_like 'an accessed value'
            end

            context 'Item description' do
                let(:column_index) {LoadPurchaseItemsCommandMock::ITEM_DESC_COLUMN}

                it_behaves_like 'an accessed value'
            end

            context 'Accounting category' do
                let(:column_index) {LoadPurchaseItemsCommandMock::ACCT_CATEGORY_COLUMN}

                it_behaves_like 'an accessed value'
            end

            context 'Taxable' do
                let(:column_index) {LoadPurchaseItemsCommandMock::TAXABLE_COLUMN}

                it_behaves_like 'an accessed value'
            end

            context 'Ordering' do
                let(:column_index) {LoadPurchaseItemsCommandMock::ORDERING_COLUMN}

                it_behaves_like 'an accessed value'
            end

            context 'Inventory' do
                let(:column_index) {LoadPurchaseItemsCommandMock::INVENTORY_COLUMN}

                it_behaves_like 'an accessed value'
            end

            context 'Begining inventory cost' do
                let(:column_index) {LoadPurchaseItemsCommandMock::BEGINNING_COST_COLUMN}

                it_behaves_like 'an accessed value'
            end

            context 'Primary vendor flag' do
                let(:column_index) {LoadPurchaseItemsCommandMock::PRIMARY_VENDOR_COLUMN}

                it_behaves_like 'an accessed value'
            end

            context 'Vendor key' do
                let(:column_index) {LoadPurchaseItemsCommandMock::VENDOR_KEY_COLUMN}

                it_behaves_like 'an accessed value'
            end

            context 'Order unit' do
                let(:column_index) {LoadPurchaseItemsCommandMock::ORDER_UNIT_COLUMN}

                it_behaves_like 'an accessed value'
            end

            context 'Pack value' do
                let(:column_index) {LoadPurchaseItemsCommandMock::PACK_VALUE_COLUMN}

                it_behaves_like 'an accessed value'
            end
        end

        context 'type conversions' do
            it 'invokes #coerce_to_boolean' do
                expect(command).to have_received(:coerce_to_boolean).exactly(4).times
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

            context 'order_unit' do
                it 'calls #get_service_provider_unit_by_unit_name' do
                    expect(command).to have_received(:get_service_provider_unit_by_unit_name).with(order_unit.name, context)
                end
            end
        end

        context 'the new inventory item' do
            inventory_item = nil

            before :each do
                inventory_item = PurchasedItem.last
            end

            it 'has the correct value for :name' do
                expect(inventory_item.name).to eq item_name
            end

            it 'has the correct value for :item_unit' do
                expect(inventory_item.item_unit).to eq item_unit
            end

            it 'has the correct value for :restaurant_identifier' do
                expect(inventory_item.restaurant_identifier).to eq restaurant_identifier
            end

            it 'has the correct value for :description' do
                expect(inventory_item.description).to eq item_description
            end

            it 'has the correct value for :accounting_category' do
                expect(inventory_item.accounting_category).to eq accounting_category
            end

            it 'has the correct value for :taxable' do
                expect(inventory_item.taxable).to eq taxable
            end

            it 'has the correct value for :ordering' do
                expect(inventory_item.ordering).to eq ordering
            end

            it 'has the correct value for :inventory' do
                expect(inventory_item.inventory).to eq inventory
            end

            it 'has the correct value for :starting_average_cost' do
                expect(inventory_item.starting_average_cost).to eq starting_average_cost.to_d
            end
        end

        context 'the new vendor item' do
            vendor_inventory_item = nil

            before :each do
                vendor_inventory_item = VendorInventoryItem.last
            end

            it 'has the correct value for :inventory_item' do
                inventory_item = PurchasedItem.last
                expect(vendor_inventory_item.inventory_item).to eq inventory_item
            end

            it 'has the correct value for :vendor' do
                expect(vendor_inventory_item.vendor).to eq vendor
            end

            it 'has the correct value for :order_unit' do
                expect(vendor_inventory_item.order_unit).to eq order_unit
            end

            it 'has the correct value for :pack_value' do
                expect(vendor_inventory_item.pack_value).to eq pack_value
            end

            it 'has the correct value for :vendor_specific_identifier' do
                expect(vendor_inventory_item.vendor_specific_identifier).to eq vendor_specific_identifier
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
    end
end
