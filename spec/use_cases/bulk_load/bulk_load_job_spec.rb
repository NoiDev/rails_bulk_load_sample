require 'rails_helper'
require 'use_cases/bulk_load/bulk_load_job'

describe 'UseCases::BulkLoad::TypeHelpers' do
    include UseCases::BulkLoad::TypeHelpers

    describe '#coerce_to_boolean' do
        shared_examples 'the value is boolean true' do
            it 'returns boolean true' do
                actual = coerce_to_boolean(parameter_value)
                expect(actual).to be true
            end
        end

        shared_examples 'the value is boolean false' do
            it 'returns boolean false' do
                actual = coerce_to_boolean(parameter_value)
                expect(actual).to be false
            end
        end

        shared_examples 'the value is NOT boolean' do
            it 'returns nil' do
                actual = coerce_to_boolean(parameter_value)
                expect(actual).to be_nil
            end
        end

        describe 'when the value is boolean true' do
            let(:parameter_value) {true}

            it_behaves_like 'the value is boolean true'

            it 'returns the original value' do
                actual = coerce_to_boolean(parameter_value)
                expect(actual).to be parameter_value
            end
        end

        describe 'when the value is boolean false' do
            let(:parameter_value) {false}

            it_behaves_like 'the value is boolean false'

            it 'returns the original value' do
                actual = coerce_to_boolean(parameter_value)
                expect(actual).to be parameter_value
            end
        end

        describe "when the value is a supported true string:" do
            describe "'true'" do
                let(:parameter_value) {'true'}

                it_behaves_like 'the value is boolean true'
            end

            describe "'yes'" do
                let(:parameter_value) {'yes'}

                it_behaves_like 'the value is boolean true'
            end

            describe "'t'" do
                let(:parameter_value) {'t'}

                it_behaves_like 'the value is boolean true'
            end

            describe "'y'" do
                let(:parameter_value) {'y'}

                it_behaves_like 'the value is boolean true'
            end
        end

        describe "when the value is a supported false string:" do
            describe "'false'" do
                let(:parameter_value) {'false'}

                it_behaves_like 'the value is boolean false'
            end

            describe "'no'" do
                let(:parameter_value) {'no'}

                it_behaves_like 'the value is boolean false'
            end

            describe "'f'" do
                let(:parameter_value) {'f'}

                it_behaves_like 'the value is boolean false'
            end

            describe "'n'" do
                let(:parameter_value) {'n'}

                it_behaves_like 'the value is boolean false'
            end
        end

        describe "when the value is a boolean-like string:" do
            describe "'trench'" do
                let(:parameter_value) {'trench'}

                it_behaves_like 'the value is NOT boolean'
            end

            describe "'factual'" do
                let(:parameter_value) {'factual'}

                it_behaves_like 'the value is NOT boolean'
            end

            describe "'yellow'" do
                let(:parameter_value) {'yellow'}

                it_behaves_like 'the value is NOT boolean'
            end

            describe "'north'" do
                let(:parameter_value) {'north'}

                it_behaves_like 'the value is NOT boolean'
            end
        end

        describe "when the value is some other string:" do
            let(:parameter_value) {'qwerty'}

            it_behaves_like 'the value is NOT boolean'
        end

        describe "when the value is an empty string" do
            let(:parameter_value) {''}

            it_behaves_like 'the value is NOT boolean'
        end

        describe 'when the value is nil' do
            let(:parameter_value) {nil}

            it_behaves_like 'the value is NOT boolean'
        end
    end

    describe '#coerce_to_date' do
        shared_examples 'the value is a Date' do
            it 'returns a Date value' do
                actual = coerce_to_date(parameter_value)
                expect(actual).to be_kind_of(Date)
            end
        end

        shared_examples 'the value is NOT a Date' do
            it 'returns nil' do
                actual = coerce_to_date(parameter_value)
                expect(actual).to be_nil
            end
        end

        describe 'when the value is a Date' do
            let(:parameter_value) {Date.today}

            it_behaves_like 'the value is a Date'

            it 'returns the original value' do
                actual = coerce_to_date(parameter_value)
                expect(actual).to be parameter_value
            end
        end

        describe 'when the value is a DateTime' do
            let(:parameter_value) {DateTime.now}

            it_behaves_like 'the value is a Date'

            it 'returns the original value' do
                actual = coerce_to_date(parameter_value)
                expect(actual).to be parameter_value
            end
        end

        describe 'when the value is a Time' do
            let(:parameter_value) {Time.now}

            it_behaves_like 'the value is NOT a Date'
        end

        describe 'when the value is a supported date string format' do
            describe '(%m/%d/%y, short month/day)' do
                let(:parameter_value) {'1/2/19'}

                it_behaves_like 'the value is a Date'

                it 'returns the correct Date value' do
                    expected_date = Date.new(2019, 1, 2)
                    actual = coerce_to_date(parameter_value)
                    expect(actual).to eq expected_date
                end
            end

            describe '(%m/%d/%y, long month/day)' do
                let(:parameter_value) {'01/02/19'}

                it_behaves_like 'the value is a Date'

                it 'returns the correct Date value' do
                    expected_date = Date.new(2019, 1, 2)
                    actual = coerce_to_date(parameter_value)
                    expect(actual).to eq expected_date
                end
            end

            describe '(%m/%d/%Y, short month/day)' do
                let(:parameter_value) {'3/4/2019'}

                it_behaves_like 'the value is a Date'

                it 'returns the correct Date value' do
                    expected_date = Date.new(2019, 3, 4)
                    actual = coerce_to_date(parameter_value)
                    expect(actual).to eq expected_date
                end
            end

            describe '(%m/%d/%Y, long month/day)' do
                let(:parameter_value) {'03/04/2019'}

                it_behaves_like 'the value is a Date'

                it 'returns the correct Date value' do
                    expected_date = Date.new(2019, 3, 4)
                    actual = coerce_to_date(parameter_value)
                    expect(actual).to eq expected_date
                end
            end

            describe '(%Y-%m-%d)' do
                let(:parameter_value) {'2019-05-06'}

                it_behaves_like 'the value is a Date'

                it 'returns the correct Date value' do
                    expected_date = Date.new(2019, 5, 6)
                    actual = coerce_to_date(parameter_value)
                    expect(actual).to eq expected_date
                end
            end
        end

        describe 'when the value is an un-supported date string format' do
            describe '(%m/%d)' do
                let(:parameter_value) {'1/2'}

                it_behaves_like 'the value is NOT a Date'
            end

            describe '(%m-%d-%y)' do
                let(:parameter_value) {'01-02-19'}

                it_behaves_like 'the value is NOT a Date'
            end
        end

        describe 'when the value is a non-date string' do
            let(:parameter_value) {'not_a_date'}

            it_behaves_like 'the value is NOT a Date'
        end

        describe 'when the value is an empty string' do
            let(:parameter_value) {''}

            it_behaves_like 'the value is NOT a Date'
        end

        describe 'when the value is an integer' do
            let(:parameter_value) {3}

            it_behaves_like 'the value is NOT a Date'
        end

        describe 'when the value is a float' do
            let(:parameter_value) {4.76}

            it_behaves_like 'the value is NOT a Date'
        end

        describe 'when the value is nil' do
            let(:parameter_value) {nil}

            it_behaves_like 'the value is NOT a Date'
        end
    end

    describe '#get_inventory_item_by_id' do
        include_context 'a mock bulk load context'

        actual = nil

        shared_examples 'the inventory_item is found' do
            before :each do
                actual = get_inventory_item_by_id(inventory_item_id,
                                                  context)
            end

            it 'returns the record' do
                expect(actual).to eq inventory_item
            end
        end

        shared_examples 'the inventory_item is NOT found' do
            before :each do
                actual = get_inventory_item_by_id(inventory_item_id,
                                                  context)
            end

            it 'returns nil' do
                expect(actual).to be_nil
            end
        end

        context 'when inventory_item exists for the restaurant' do
            include_context 'a single inventory item'

            let(:inventory_item_id) {inventory_item.id}

            it_behaves_like 'the inventory_item is found'
        end

        context 'when inventory_item exists for a different restaurant' do
            include_context 'core domain model for inventory items'
            include_context 'two restaurants'

            let(:inventory_item) {
                create(:purchased_item,
                       service_provider: another_restaurant,
                       accounting_category_id: accounting_category.id)
            }

            let(:inventory_item_id) {inventory_item.id}

            it_behaves_like 'the inventory_item is NOT found'
        end

        context 'when inventory_item does NOT exist' do
            let(:inventory_item_id) {999}

            it_behaves_like 'the inventory_item is NOT found'
        end

        context 'when inventory_item_id is NOT a valid id:' do
            context '(letters)' do
                let(:inventory_item_id) {'a'}

                it_behaves_like 'the inventory_item is NOT found'
            end

            context '(empty string)' do
                let(:inventory_item_id) {''}

                it_behaves_like 'the inventory_item is NOT found'
            end

            context '(nil)' do
                let(:inventory_item_id) {nil}

                it_behaves_like 'the inventory_item is NOT found'
            end
        end
    end

    describe '#get_vendor_by_key' do
        include_context 'a mock bulk load context'

        actual = nil

        shared_examples 'the vendor is found' do
            before :each do
                actual = get_vendor_by_key(vendor_key,
                                           context)
            end

            it 'returns the record' do
                expect(actual).to eq vendor
            end
        end

        shared_examples 'the vendor is NOT found' do
            before :each do
                actual = get_vendor_by_key(vendor_key,
                                           context)
            end

            it 'returns nil' do
                expect(actual).to be_nil
            end
        end

        context 'when vendor exists for the restaurant:' do
            include_context 'a vendor'

            before :each do
                # Note: Use a mixed-case key to ensure that the case-insensitive logic works.
                vendor.key = 'aStrange_Key'
                vendor.save!
            end

            context '(matched case)' do
                let(:vendor_key) {vendor.key}

                it_behaves_like 'the vendor is found'
            end

            context '(lower case)' do
                let(:vendor_key) {vendor.key.downcase}

                it_behaves_like 'the vendor is found'
            end

            context '(upper case)' do
                let(:vendor_key) {vendor.key.upcase}

                it_behaves_like 'the vendor is found'
            end

            context '(mixed case)' do
                let(:vendor_key) {vendor.key.swapcase}

                it_behaves_like 'the vendor is found'
            end
        end

        context 'when vendor exists for a different restaurant' do
            include_context 'core domain model for inventory items'
            include_context 'two restaurants'

            let(:vendor_from_another_restaurant) {
                create :vendor,
                    service_provider: another_restaurant
            }

            let(:vendor_key) {vendor_from_another_restaurant.key}

            it_behaves_like 'the vendor is NOT found'
        end

        context 'when vendor does NOT exist' do
            let(:vendor_key) {'restaurant_non_existant_vendor'}

            it_behaves_like 'the vendor is NOT found'
        end

        context 'when vendor_key is NOT a valid vendor_key:' do
            context '(numbers)' do
                let(:vendor_key) {123}

                it_behaves_like 'the vendor is NOT found'
            end

            context '(empty string)' do
                let(:vendor_key) {''}

                it_behaves_like 'the vendor is NOT found'
            end

            context '(nil)' do
                let(:vendor_key) {nil}

                it_behaves_like 'the vendor is NOT found'
            end
        end
    end

    describe '#get_accounting_category_by_name' do
        include_context 'a mock bulk load context'

        actual = nil

        shared_examples 'the accounting_category is found' do
            before :each do
                actual = get_accounting_category_by_name(name,
                                                         context)
            end

            it 'returns the record' do
                expect(actual).to eq accounting_category
            end
        end

        shared_examples 'the accounting_category is NOT found' do
            before :each do
                actual = get_accounting_category_by_name(name,
                                                         context)
            end

            it 'returns nil' do
                expect(actual).to be_nil
            end
        end

        context 'when accounting_category exists for the restaurant:' do
            include_context 'an accounting category'

            context '(matched case)' do
                let(:name) {accounting_category.name}

                it_behaves_like 'the accounting_category is found'
            end

            context '(lower case)' do
                let(:name) {accounting_category.name.downcase}

                it_behaves_like 'the accounting_category is found'
            end

            context '(upper case)' do
                let(:name) {accounting_category.name.upcase}

                it_behaves_like 'the accounting_category is found'
            end

            context '(mixed case)' do
                let(:name) {accounting_category.name.swapcase}

                it_behaves_like 'the accounting_category is found'
            end
        end

        context 'when accounting_category exists for a different restaurant' do
            include_context 'core domain model for inventory items'
            include_context 'two restaurants'

            let(:accounting_category_from_another_restaurant) {
                create :accounting_category,
                    name: 'Name from other restaurant',
                    service_provider: another_restaurant
            }

            let(:name) {accounting_category_from_another_restaurant.name}

            it_behaves_like 'the accounting_category is NOT found'
        end

        context 'when accounting_category does NOT exist' do
            let(:name) {'restaurant_non_existant_accounting_category'}

            it_behaves_like 'the accounting_category is NOT found'
        end

        context 'when name is NOT a valid name:' do
            context '(numbers)' do
                let(:name) {123}

                it_behaves_like 'the accounting_category is NOT found'
            end

            context '(empty string)' do
                let(:name) {''}

                it_behaves_like 'the accounting_category is NOT found'
            end

            context '(nil)' do
                let(:name) {nil}

                it_behaves_like 'the accounting_category is NOT found'
            end
        end
    end

    describe '#get_service_provider_unit_by_unit_name' do
        include_context 'a mock bulk load context'

        actual = nil

        shared_examples 'the service_provider_unit is found' do
            before :each do
                actual = get_service_provider_unit_by_unit_name(unit_name,
                                                                context)
            end

            it 'returns the record' do
                expect(actual).to eq service_provider_unit
            end
        end

        shared_examples 'the service_provider_unit is NOT found' do
            before :each do
                actual = get_service_provider_unit_by_unit_name(unit_name,
                                                                context)
            end

            it 'returns nil' do
                expect(actual).to be_nil
            end
        end

        context 'when service_provider_unit exists for the restaurant:' do
            include_context 'unit instances'

            let(:service_provider_unit) {service_provider_unit_bag}

            context '(matched case)' do
                let(:unit_name) {service_provider_unit.name}

                it_behaves_like 'the service_provider_unit is found'
            end

            context '(lower case)' do
                let(:unit_name) {service_provider_unit.name.downcase}

                it_behaves_like 'the service_provider_unit is found'
            end

            context '(upper case)' do
                let(:unit_name) {service_provider_unit.name.upcase}

                it_behaves_like 'the service_provider_unit is found'
            end

            context '(mixed case)' do
                let(:unit_name) {service_provider_unit.name.swapcase}

                it_behaves_like 'the service_provider_unit is found'
            end
        end

        context 'when service_provider_unit exists for a different restaurant' do
            include_context 'core domain model for inventory items'
            include_context 'two restaurants'

            let(:some_other_unit) {
                create :unit, name: 'Other Unit'
            }

            let(:service_provider_unit_from_another_restaurant) {
                create :service_provider_unit,
                    unit: some_other_unit,
                    service_provider: another_restaurant
            }

            let(:unit_name) {service_provider_unit_from_another_restaurant.name}

            it_behaves_like 'the service_provider_unit is NOT found'
        end

        context 'when service_provider_unit does NOT exist' do
            let(:unit_name) {'restaurant_non_existant_service_provider_unit'}

            it_behaves_like 'the service_provider_unit is NOT found'
        end

        context 'when unit_name is NOT a valid unit_name:' do
            context '(numbers)' do
                let(:unit_name) {123}

                it_behaves_like 'the service_provider_unit is NOT found'
            end

            context '(empty string)' do
                let(:unit_name) {''}

                it_behaves_like 'the service_provider_unit is NOT found'
            end

            context '(nil)' do
                let(:unit_name) {nil}

                it_behaves_like 'the service_provider_unit is NOT found'
            end
        end
    end
end

describe 'UseCases::BulkLoad::VerifyDataCommand' do
    include_context 'a mock bulk load context'

    let(:command) {UseCases::BulkLoad::VerifyDataCommand.new}

    describe '#execute' do
        let(:first_row_index) {0}
        let(:last_row_index) {3}

        before :each do
            allow(command).to receive(:get_first_row_index) {first_row_index}
            allow(command).to receive(:get_last_row_index) {last_row_index}
            allow(command).to receive(:before_verify_all_rows)
            allow(command).to receive(:after_verify_all_rows)
            allow(command).to receive(:verify_row)

            command.execute(context)
        end

        it 'skips the first row' do
            expect(command).not_to have_received(:verify_row).with(first_row_index, context)
        end

        it 'calls #before_verify_all_rows' do
            expect(command).to have_received(:before_verify_all_rows).with(context)
        end

        it 'calls #verify_row on all other rows' do
            expect(command).to have_received(:verify_row).with(1, context)
            expect(command).to have_received(:verify_row).with(2, context)
            expect(command).to have_received(:verify_row).with(last_row_index, context)
            expect(command).to have_received(:verify_row).exactly(last_row_index).times
        end

        it 'calls #after_verify_all_rows' do
            expect(command).to have_received(:after_verify_all_rows).with(context)
        end

        it 'sets :total_items_count' do
            expect(context.bulk_load_inventory_items_job.total_items_count).to eq 3
        end
    end

    describe '#create_error' do
        let(:row_index) {1}
        let(:column_index) {2}
        let(:error_message) {'Sample error message'}

        before :each do
            command.send(:create_error,
                         row_index,
                         column_index,
                         error_message,
                         context)

            bulk_load_inventory_items_job.reload
        end

        it 'creates a new error' do
            expect(bulk_load_inventory_items_job.bulk_load_inventory_items_job_errors.count).to eq 1
        end

        describe 'the new error object' do
            actual = nil

            before :each do
                actual = bulk_load_inventory_items_job.bulk_load_inventory_items_job_errors[0]
            end

            it 'has the correct properties: :spreadsheet_row' do
                expect(actual.spreadsheet_row).to eq row_index
            end

            it 'has the correct properties: :spreadsheet_column' do
                expect(actual.spreadsheet_column).to eq column_index
            end

            it 'has the correct properties: :description' do
                expect(actual.description).to eq error_message
            end

            it 'has the correct properties: :bulk_load_inventory_items_job' do
                expect(actual.bulk_load_inventory_items_job).to eq bulk_load_inventory_items_job
            end
        end
    end

    describe '#build_column_names_array' do
        # Note: This is a template method intended to be overloaded.
        it 'returns an array' do
            actual = command.send(:build_column_names_array)
            expect(actual).to be_kind_of(Array)
        end
    end

    describe '#get_name_for_column' do
        let(:parameter_name) {'Sample Parameter'}
        let(:column_names) {[parameter_name]}

        before :each do
            allow(command).to receive(:build_column_names_array) {column_names}
        end

        context 'when the name is defined for the column' do
            let(:column_index) {0}

            it 'returns the name' do
                actual = command.send(:get_name_for_column, column_index)
                expect(actual).to eq parameter_name
            end
        end

        context 'when the name is defined for the column' do
            let(:column_index) {999}

            it 'returns COLUMN_NAME_UNKNOWN' do
                actual = command.send(:get_name_for_column, column_index)
                expect(actual).to eq UseCases::BulkLoad::VerifyDataCommand::COLUMN_NAME_UNKNOWN
            end
        end

        context 'initializing the source array' do
            it 'loads the array on the initial call' do
                command.send(:get_name_for_column, 0)
                expect(command).to have_received(:build_column_names_array).once
            end

            it 'does NOT load the array on subsequent calls' do
                command.send(:get_name_for_column, 0)
                command.send(:get_name_for_column, 1)
                command.send(:get_name_for_column, 2)
                expect(command).to have_received(:build_column_names_array).once
            end
        end

    end

    shared_context 'validator spec setup' do
        let(:parameter_name) {'Sample Parameter'}
        let(:row_index) {1}
        let(:column_index) {2}

        before :each do
            allow(command).to receive(:get_value_for_cell).with(row_index, column_index, context) {parameter_value}
            allow(command).to receive(:get_name_for_column) {parameter_name}
            allow(command).to receive(:create_error)
        end
    end

    describe '#get_required_parameter' do
        include_context 'validator spec setup'

        actual = nil

        shared_examples 'the parameter is present' do
            before :each do
                actual = command.send(:get_required_parameter,
                                      row_index,
                                      column_index,
                                      context)
            end

            it 'returns the value' do
                expect(actual).to eq parameter_value
            end

            it 'does NOT create an error' do
                expect(command).not_to have_received(:create_error)
            end
        end

        shared_examples 'the parameter is NOT present' do
            before :each do
                actual = command.send(:get_required_parameter,
                                      row_index,
                                      column_index,
                                      context)
            end

            it 'returns nil' do
                expect(actual).to be_nil
            end

            it 'loads the column name' do
                expect(command).to have_received(:get_name_for_column).with(column_index)
            end

            it 'creates an error' do
                error_message = "The \"#{parameter_name}\" (column #{column_index}) is a required data item."
                expect(command).to have_received(:create_error).with(row_index,
                                                                     column_index,
                                                                     error_message,
                                                                     context)
            end
        end

        describe 'when the parameter is NOT nil' do
            context '(boolean true)' do
                let(:parameter_value) {true}

                it_behaves_like 'the parameter is present'
            end

            context '(boolean false)' do
                let(:parameter_value) {false}

                it_behaves_like 'the parameter is present'
            end

            context '(string)' do
                let(:parameter_value) {'a_string'}

                it_behaves_like 'the parameter is present'
            end

            describe '(empty string)' do
                let(:parameter_value) {''}

                it_behaves_like 'the parameter is present'
            end

            context '(number)' do
                let(:parameter_value) {12.345}

                it_behaves_like 'the parameter is present'
            end

            context '(number zero)' do
                let(:parameter_value) {0.0}

                it_behaves_like 'the parameter is present'
            end

            context '(date)' do
                let(:parameter_value) {Date.new}

                it_behaves_like 'the parameter is present'
            end
        end

        describe 'when the parameter is nil' do
            let(:parameter_value) {nil}

            it_behaves_like 'the parameter is NOT present'
        end
    end

    describe '#get_optional_parameter' do
        include_context 'validator spec setup'

        actual = nil

        shared_examples 'the parameter is present' do
            before :each do
                actual = command.send(:get_optional_parameter,
                                      row_index,
                                      column_index,
                                      context)
            end

            it 'returns the value' do
                expect(actual).to eq parameter_value
            end

            it 'does NOT create an error' do
                expect(command).not_to have_received(:create_error)
            end
        end

        shared_examples 'the parameter is NOT present' do
            before :each do
                actual = command.send(:get_optional_parameter,
                                      row_index,
                                      column_index,
                                      context)
            end

            it 'returns nil' do
                expect(actual).to be_nil
            end

            it 'does NOT create an error' do
                expect(command).not_to have_received(:create_error)
            end
        end

        describe 'when the parameter is NOT nil' do
            context '(boolean true)' do
                let(:parameter_value) {true}

                it_behaves_like 'the parameter is present'
            end

            context '(boolean false)' do
                let(:parameter_value) {false}

                it_behaves_like 'the parameter is present'
            end

            context '(string)' do
                let(:parameter_value) {'a_string'}

                it_behaves_like 'the parameter is present'
            end

            describe '(empty string)' do
                let(:parameter_value) {''}

                it_behaves_like 'the parameter is present'
            end

            context '(number)' do
                let(:parameter_value) {12.345}

                it_behaves_like 'the parameter is present'
            end

            context '(number zero)' do
                let(:parameter_value) {0.0}

                it_behaves_like 'the parameter is present'
            end

            context '(date)' do
                let(:parameter_value) {Date.new}

                it_behaves_like 'the parameter is present'
            end
        end

        describe 'when the parameter is nil' do
            let(:parameter_value) {nil}

            it_behaves_like 'the parameter is NOT present'
        end
    end

    describe '#require_blank_cell' do
        include_context 'validator spec setup'

        let(:explanation) {'The item is not configured for ordering'}

        actual = nil

        shared_examples 'the cell is blank' do
            before :each do
                actual = command.send(:require_blank_cell,
                                      row_index,
                                      column_index,
                                      context,
                                      explanation)
            end

            it 'returns true' do
                expect(actual).to be_truthy
            end

            it 'does NOT create an error' do
                expect(command).not_to have_received(:create_error)
            end
        end

        shared_examples 'the cell is NOT blank' do
            before :each do
                actual = command.send(:require_blank_cell,
                                      row_index,
                                      column_index,
                                      context,
                                      explanation)
            end

            it 'returns false' do
                expect(actual).to be_falsy
            end

            it 'loads the column name' do
                expect(command).to have_received(:get_name_for_column).with(column_index)
            end

            it 'creates an error' do
                error_message = "The #{parameter_name} (column #{column_index}) must must be blank."
                error_message += " (#{explanation})"
                expect(command).to have_received(:create_error).with(row_index,
                                                                     column_index,
                                                                     error_message,
                                                                     context)
            end
        end

        describe 'when the parameter is NOT nil' do
            context '(boolean true)' do
                let(:parameter_value) {true}

                it_behaves_like 'the cell is NOT blank'
            end

            context '(boolean false)' do
                let(:parameter_value) {false}

                it_behaves_like 'the cell is NOT blank'
            end

            context '(string)' do
                let(:parameter_value) {'a_string'}

                it_behaves_like 'the cell is NOT blank'
            end

            describe '(blank, non-empty string)' do
                let(:parameter_value) {' '}

                it_behaves_like 'the cell is NOT blank'
            end

            context '(number)' do
                let(:parameter_value) {12.345}

                it_behaves_like 'the cell is NOT blank'
            end

            context '(number zero)' do
                let(:parameter_value) {0.0}

                it_behaves_like 'the cell is NOT blank'
            end

            context '(date)' do
                let(:parameter_value) {Date.new}

                it_behaves_like 'the cell is NOT blank'
            end
        end

        context 'blank cells:' do
            describe '(empty string)' do
                let(:parameter_value) {''}

                it_behaves_like 'the cell is blank'
            end

            describe '(nil)' do
                let(:parameter_value) {nil}

                it_behaves_like 'the cell is blank'
            end
        end
    end

    describe '#restrict_type_to_boolean' do
        include_context 'validator spec setup'

        actual = nil

        shared_examples 'the value is boolean' do
            before :each do
                actual = command.send(:restrict_type_to_boolean,
                                      parameter_value,
                                      row_index,
                                      column_index,
                                      context)
            end

            it 'calls #coerce_to_boolean' do
                expect(command).to have_received(:coerce_to_boolean).with(parameter_value)
            end

            it 'returns true' do
                expect(actual).to be_truthy
            end

            it 'does NOT create an error' do
                expect(command).not_to have_received(:create_error)
            end
        end

        shared_examples 'the value is NOT boolean' do
            before :each do
                actual = command.send(:restrict_type_to_boolean,
                                      parameter_value,
                                      row_index,
                                      column_index,
                                      context)
            end

            it 'calls #coerce_to_boolean' do
                expect(command).to have_received(:coerce_to_boolean).with(parameter_value)
            end

            it 'returns false' do
                expect(actual).to be_falsy
            end

            it 'loads the column name' do
                expect(command).to have_received(:get_name_for_column).with(column_index)
            end

            it 'creates an error' do
                error_message = "The value #{parameter_value.inspect} for \"#{parameter_name}\" (column #{column_index}) must be a boolean value (true/false, yes/no)."
                expect(command).to have_received(:create_error).with(row_index,
                                                                     column_index,
                                                                     error_message,
                                                                     context)
            end
        end

        before :each do
            allow(command).to receive(:coerce_to_boolean).and_call_original
        end

        describe 'when the parameter is boolean true' do
            let(:parameter_value) {true}

            it_behaves_like 'the value is boolean'
        end

        describe 'when the parameter is boolean false' do
            let(:parameter_value) {false}

            it_behaves_like 'the value is boolean'
        end

        describe 'when the parameter coerces to boolean true' do
            let(:parameter_value) {'true'}

            it_behaves_like 'the value is boolean'
        end

        describe 'when the parameter coerces to boolean false' do
            let(:parameter_value) {'false'}

            it_behaves_like 'the value is boolean'
        end

        describe 'when the parameter does NOT coerce to a boolean value (string)' do
            let(:parameter_value) {'not_a_valid_boolean_string'}

            it_behaves_like 'the value is NOT boolean'
        end

        describe 'when the parameter does NOT coerce to a boolean value (number)' do
            let(:parameter_value) {123}

            it_behaves_like 'the value is NOT boolean'
        end

        describe 'when the parameter is nil' do
            let(:parameter_value) {nil}

            it_behaves_like 'the value is NOT boolean'
        end
    end

    describe '#restrict_type_to_date' do
        include_context 'validator spec setup'

        actual = nil

        shared_examples 'the value is a Date' do
            before :each do
                actual = command.send(:restrict_type_to_date,
                                      parameter_value,
                                      row_index,
                                      column_index,
                                      context)
            end

            it 'calls #coerce_to_date' do
                expect(command).to have_received(:coerce_to_date).with(parameter_value)
            end

            it 'returns true' do
                expect(actual).to be_truthy
            end

            it 'does NOT create an error' do
                expect(command).not_to have_received(:create_error)
            end
        end

        shared_examples 'the value is NOT a Date' do
            before :each do
                actual = command.send(:restrict_type_to_date,
                                      parameter_value,
                                      row_index,
                                      column_index,
                                      context)
            end

            it 'calls #coerce_to_date' do
                expect(command).to have_received(:coerce_to_date).with(parameter_value)
            end

            it 'returns false' do
                expect(actual).to be_falsy
            end

            it 'loads the column name' do
                expect(command).to have_received(:get_name_for_column).with(column_index)
            end

            it 'creates an error' do
                error_message = "The value #{parameter_value.inspect} for \"#{parameter_name}\" (column #{column_index}) must be a date value (mm/dd/yy, mm/dd/yyyy, yyyy-mm-dd)."
                expect(command).to have_received(:create_error).with(row_index,
                                                                     column_index,
                                                                     error_message,
                                                                     context)
            end
        end

        before :each do
            allow(command).to receive(:coerce_to_date).and_call_original
        end

        describe 'when the parameter is a Date' do
            let(:parameter_value) {Date.today}

            it_behaves_like 'the value is a Date'
        end

        describe 'when the parameter coerces to a Date' do
            let(:parameter_value) {'01/02/19'}

            it_behaves_like 'the value is a Date'
        end

        describe 'when the parameter does NOT coerce to a Date' do
            let(:parameter_value) {'not_a_date'}

            it_behaves_like 'the value is NOT a Date'
        end

        describe 'when the parameter is nil' do
            let(:parameter_value) {nil}

            it_behaves_like 'the value is NOT a Date'
        end
    end

    describe '#restrict_type_to_integer' do
        include_context 'validator spec setup'

        actual = nil

        shared_examples 'the value is an integer' do
            before :each do
                actual = command.send(:restrict_type_to_integer,
                                      parameter_value,
                                      row_index,
                                      column_index,
                                      context)
            end

            it 'returns true' do
                expect(actual).to be_truthy
            end

            it 'does NOT create an error' do
                expect(command).not_to have_received(:create_error)
            end
        end

        shared_examples 'the value is NOT an integer' do
            before :each do
                actual = command.send(:restrict_type_to_integer,
                                      parameter_value,
                                      row_index,
                                      column_index,
                                      context)
            end

            it 'returns false' do
                expect(actual).to be_falsy
            end

            it 'loads the column name' do
                expect(command).to have_received(:get_name_for_column).with(column_index)
            end

            it 'creates an error' do
                error_message = "The value #{parameter_value.inspect} for \"#{parameter_name}\" (column #{column_index}) must be an integer."
                expect(command).to have_received(:create_error).with(row_index,
                                                                     column_index,
                                                                     error_message,
                                                                     context)
            end
        end

        context 'when the parameter is a native integer' do
            context '(positive)' do
                let(:parameter_value) {123}

                it_behaves_like 'the value is an integer'
            end

            context '(negative)' do
                let(:parameter_value) {-456}

                it_behaves_like 'the value is an integer'
            end

            context '(zero)' do
                let(:parameter_value) {0}

                it_behaves_like 'the value is an integer'
            end
        end

        context 'when the parameter is a native float' do
            context '(positive)' do
                let(:parameter_value) {1.2345}

                it_behaves_like 'the value is an integer'
            end

            context '(negative)' do
                let(:parameter_value) {-45.678}

                it_behaves_like 'the value is an integer'
            end

            context '(zero)' do
                let(:parameter_value) {0.0}

                it_behaves_like 'the value is an integer'
            end
        end

        describe 'when the parameter is a string parseable to an integer:' do
            context "'123'" do
                let(:parameter_value) {'123'}

                it_behaves_like 'the value is an integer'
            end

            context "'-123'" do
                let(:parameter_value) {'-123'}

                it_behaves_like 'the value is an integer'
            end

            context "'0'" do
                let(:parameter_value) {'0'}

                it_behaves_like 'the value is an integer'
            end

            context "'00'" do
                let(:parameter_value) {'00'}

                it_behaves_like 'the value is an integer'
            end
        end

        describe 'when the parameter is un-parseable but is integer-like:' do
            context "'a123'" do
                let(:parameter_value) {'a123'}

                it_behaves_like 'the value is NOT an integer'
            end

            context "'12b3'" do
                let(:parameter_value) {'12b3'}

                it_behaves_like 'the value is NOT an integer'
            end

            context "'123c'" do
                let(:parameter_value) {'123c'}

                it_behaves_like 'the value is NOT an integer'
            end

            context "'1,234'" do
                let(:parameter_value) {'1,23'}

                it_behaves_like 'the value is NOT an integer'
            end
        end

        describe 'when the parameter is a string is NOT integer-like:' do
            context "(no numbers)" do
                let(:parameter_value) {'not_a_integer'}

                it_behaves_like 'the value is NOT an integer'
            end

            context "(empty string)" do
                let(:parameter_value) {''}

                it_behaves_like 'the value is NOT an integer'
            end
        end

        describe 'when the parameter is nil' do
            let(:parameter_value) {nil}

            it_behaves_like 'the value is NOT an integer'
        end
    end

    describe '#restrict_type_to_decimal' do
        include_context 'validator spec setup'

        actual = nil

        shared_examples 'the value is a decimal' do
            before :each do
                actual = command.send(:restrict_type_to_decimal,
                                      parameter_value,
                                      row_index,
                                      column_index,
                                      context)
            end

            it 'returns true' do
                expect(actual).to be_truthy
            end

            it 'does NOT create an error' do
                expect(command).not_to have_received(:create_error)
            end
        end

        shared_examples 'the value is NOT a decimal' do
            before :each do
                actual = command.send(:restrict_type_to_decimal,
                                      parameter_value,
                                      row_index,
                                      column_index,
                                      context)
            end

            it 'returns false' do
                expect(actual).to be_falsy
            end

            it 'loads the column name' do
                expect(command).to have_received(:get_name_for_column).with(column_index)
            end

            it 'creates an error' do
                error_message = "The value #{parameter_value.inspect} for \"#{parameter_name}\" (column #{column_index}) must be a number."
                expect(command).to have_received(:create_error).with(row_index,
                                                                     column_index,
                                                                     error_message,
                                                                     context)
            end
        end

        context 'when the parameter is a native integer' do
            context '(positive)' do
                let(:parameter_value) {123}

                it_behaves_like 'the value is a decimal'
            end

            context '(negative)' do
                let(:parameter_value) {-456}

                it_behaves_like 'the value is a decimal'
            end

            context '(zero)' do
                let(:parameter_value) {0}

                it_behaves_like 'the value is a decimal'
            end
        end

        context 'when the parameter is a native float' do
            context '(positive)' do
                let(:parameter_value) {1.2345}

                it_behaves_like 'the value is a decimal'
            end

            context '(negative)' do
                let(:parameter_value) {-45.678}

                it_behaves_like 'the value is a decimal'
            end

            context '(zero)' do
                let(:parameter_value) {0.0}

                it_behaves_like 'the value is a decimal'
            end
        end

        describe 'when the parameter is a string parseable to a decimal:' do
            context "'123'" do
                let(:parameter_value) {'123'}

                it_behaves_like 'the value is a decimal'
            end

            context "'123.'" do
                let(:parameter_value) {'123.'}

                it_behaves_like 'the value is a decimal'
            end

            context "'123.456'" do
                let(:parameter_value) {'123.456'}

                it_behaves_like 'the value is a decimal'
            end

            context "'.456'" do
                let(:parameter_value) {'.456'}

                it_behaves_like 'the value is a decimal'
            end

            context "'-123'" do
                let(:parameter_value) {'-123'}

                it_behaves_like 'the value is a decimal'
            end

            context "'-123.'" do
                let(:parameter_value) {'-123.'}

                it_behaves_like 'the value is a decimal'
            end

            context "'-123.456'" do
                let(:parameter_value) {'-123.456'}

                it_behaves_like 'the value is a decimal'
            end

            context "'-.456'" do
                let(:parameter_value) {'-.456'}

                it_behaves_like 'the value is a decimal'
            end

            context "'1.0'" do
                let(:parameter_value) {'1.0'}

                it_behaves_like 'the value is a decimal'
            end

            context "'1.00'" do
                let(:parameter_value) {'1.00'}

                it_behaves_like 'the value is a decimal'
            end
        end

        describe 'when the parameter is un-parseable but is decimal-like:' do
            context "'a123'" do
                let(:parameter_value) {'a123'}

                it_behaves_like 'the value is NOT a decimal'
            end

            context "'12b3'" do
                let(:parameter_value) {'12b3'}

                it_behaves_like 'the value is NOT a decimal'
            end

            context "'123c'" do
                let(:parameter_value) {'123c'}

                it_behaves_like 'the value is NOT a decimal'
            end

            context "'..123'" do
                let(:parameter_value) {'..123'}

                it_behaves_like 'the value is NOT a decimal'
            end

            context "'1..23'" do
                let(:parameter_value) {'1..23'}

                it_behaves_like 'the value is NOT a decimal'
            end

            context "'123..'" do
                let(:parameter_value) {'123..'}

                it_behaves_like 'the value is NOT a decimal'
            end

            context "'.1.23'" do
                let(:parameter_value) {'.1.23'}

                it_behaves_like 'the value is NOT a decimal'
            end

            context "'1.23.'" do
                let(:parameter_value) {'1.23.'}

                it_behaves_like 'the value is NOT a decimal'
            end

            context "'1,23'" do
                let(:parameter_value) {'1,23'}

                it_behaves_like 'the value is NOT a decimal'
            end
        end

        describe 'when the parameter is a string is NOT decimal-like:' do
            context "(no numbers)" do
                let(:parameter_value) {'not_a_decimal'}

                it_behaves_like 'the value is NOT a decimal'
            end

            context "(empty string)" do
                let(:parameter_value) {''}

                it_behaves_like 'the value is NOT a decimal'
            end
        end

        describe 'when the parameter is nil' do
            let(:parameter_value) {nil}

            it_behaves_like 'the value is NOT a decimal'
        end
    end

    describe '#restrict_value_non_negative' do
        include_context 'validator spec setup'

        actual = nil

        shared_examples 'the value passes validation' do
            before :each do
                actual = command.send(:restrict_value_non_negative,
                                      parameter_value,
                                      row_index,
                                      column_index,
                                      context)
            end

            it 'returns true' do
                expect(actual).to be_truthy
            end

            it 'does NOT create an error' do
                expect(command).not_to have_received(:create_error)
            end
        end

        shared_examples 'the value fails validation' do
            before :each do
                actual = command.send(:restrict_value_non_negative,
                                      parameter_value,
                                      row_index,
                                      column_index,
                                      context)
            end

            it 'returns false' do
                expect(actual).to be_falsy
            end

            it 'loads the column name' do
                expect(command).to have_received(:get_name_for_column).with(column_index)
            end

            it 'creates an error' do
                error_message = "The value #{parameter_value.inspect} for \"#{parameter_name}\" (column #{column_index}) cannot be negative."
                expect(command).to have_received(:create_error).with(row_index,
                                                                     column_index,
                                                                     error_message,
                                                                     context)
            end
        end

        context 'the parameter_value is negative:' do
            context '(native integer)' do
                let(:parameter_value) {-1}

                it_behaves_like 'the value fails validation'
            end

            context '(native decimal)' do
                let(:parameter_value) {-1.0}

                it_behaves_like 'the value fails validation'
            end

            context '(string integer)' do
                let(:parameter_value) {'-1'}

                it_behaves_like 'the value fails validation'
            end

            context '(string decimal)' do
                let(:parameter_value) {'-1.0'}

                it_behaves_like 'the value fails validation'
            end
        end

        context 'the parameter_value is zero:' do
            context '(native integer)' do
                let(:parameter_value) {0}

                it_behaves_like 'the value passes validation'
            end

            context '(native decimal)' do
                let(:parameter_value) {0.0}

                it_behaves_like 'the value passes validation'
            end

            context '(string integer)' do
                let(:parameter_value) {'0'}

                it_behaves_like 'the value passes validation'
            end

            context '(string decimal)' do
                let(:parameter_value) {'0.0'}

                it_behaves_like 'the value passes validation'
            end
        end

        context 'the parameter_value is positive:' do
            context '(native integer)' do
                let(:parameter_value) {1}

                it_behaves_like 'the value passes validation'
            end

            context '(native decimal)' do
                let(:parameter_value) {1.0}

                it_behaves_like 'the value passes validation'
            end

            context '(string integer)' do
                let(:parameter_value) {'1'}

                it_behaves_like 'the value passes validation'
            end

            context '(string decimal)' do
                let(:parameter_value) {'1.0'}

                it_behaves_like 'the value passes validation'
            end
        end
    end

    describe '#get_required_record_inventory_item_by_id' do
        include_context 'validator spec setup'
        include_context 'a single inventory item'

        let(:inventory_item_id) {inventory_item.id}

        actual = nil

        context 'the inventory_item is found' do
            before :each do
                allow(command).to receive(:get_inventory_item_by_id).and_call_original

                actual = command.send(:get_required_record_inventory_item_by_id,
                                      inventory_item_id,
                                      row_index,
                                      column_index,
                                      context)
            end

            it 'calls #get_inventory_item_by_id' do
                expect(command).to have_received(:get_inventory_item_by_id)
            end

            it 'returns the record' do
                expect(actual).to eq inventory_item
            end

            it 'does NOT create an error' do
                expect(command).not_to have_received(:create_error)
            end
        end

        shared_examples 'the inventory_item is NOT found' do
            before :each do
                allow(command).to receive(:get_inventory_item_by_id) {nil}

                actual = command.send(:get_required_record_inventory_item_by_id,
                                      inventory_item_id,
                                      row_index,
                                      column_index,
                                      context)
            end

            it 'calls #get_inventory_item_by_id' do
                expect(command).to have_received(:get_inventory_item_by_id)
            end

            it 'returns nil' do
                expect(actual).to be_nil
            end

            it 'creates an error' do
                error_message = "No inventory_item with ID ##{inventory_item_id.inspect} (column #{column_index}) was found for this restaurant."
                expect(command).to have_received(:create_error).with(row_index,
                                                                     column_index,
                                                                     error_message,
                                                                     context)
            end
        end
    end

    describe '#get_required_record_vendor_by_key' do
        include_context 'validator spec setup'
        include_context 'a vendor'

        let(:vendor_key) {vendor.key}

        actual = nil

        context 'the vendor is found' do
            before :each do
                allow(command).to receive(:get_vendor_by_key).and_call_original

                actual = command.send(:get_required_record_vendor_by_key,
                                      vendor_key,
                                      row_index,
                                      column_index,
                                      context)
            end

            it 'calls #get_vendor_by_key' do
                expect(command).to have_received(:get_vendor_by_key)
            end

            it 'returns the record' do
                expect(actual).to eq vendor
            end

            it 'does NOT create an error' do
                expect(command).not_to have_received(:create_error)
            end
        end

        context 'the vendor is NOT found' do
            before :each do
                allow(command).to receive(:get_vendor_by_key) {nil}

                actual = command.send(:get_required_record_vendor_by_key,
                                      vendor_key,
                                      row_index,
                                      column_index,
                                      context)
            end

            it 'calls #get_vendor_by_key' do
                expect(command).to have_received(:get_vendor_by_key)
            end

            it 'returns nil' do
                expect(actual).to be_nil
            end

            it 'creates an error' do
                error_message = "No vendor with key #{vendor_key.inspect} (column #{column_index}) was found for this restaurant."
                expect(command).to have_received(:create_error).with(row_index,
                                                                     column_index,
                                                                     error_message,
                                                                     context)
            end
        end
    end

    describe '#get_required_record_accounting_category_by_name' do
        include_context 'validator spec setup'
        include_context 'an accounting category'

        let(:name) {accounting_category.name}

        actual = nil

        context 'the accounting_category is found' do
            before :each do
                allow(command).to receive(:get_accounting_category_by_name).and_call_original

                actual = command.send(:get_required_record_accounting_category_by_name,
                                      name,
                                      row_index,
                                      column_index,
                                      context)
            end

            it 'calls #get_accounting_category_by_name' do
                expect(command).to have_received(:get_accounting_category_by_name)
            end

            it 'returns the record' do
                expect(actual).to eq accounting_category
            end

            it 'does NOT create an error' do
                expect(command).not_to have_received(:create_error)
            end
        end

        context 'the accounting_category is NOT found' do
            before :each do
                allow(command).to receive(:get_accounting_category_by_name) {nil}

                actual = command.send(:get_required_record_accounting_category_by_name,
                                      name,
                                      row_index,
                                      column_index,
                                      context)
            end

            it 'calls #get_accounting_category_by_name' do
                expect(command).to have_received(:get_accounting_category_by_name)
            end

            it 'returns nil' do
                expect(actual).to be_nil
            end

            it 'creates an error' do
                error_message = "No accounting_category with name #{name.inspect} (column #{column_index}) was found for this restaurant."
                expect(command).to have_received(:create_error).with(row_index,
                                                                     column_index,
                                                                     error_message,
                                                                     context)
            end
        end
    end

    describe '#get_required_record_service_provider_unit_by_unit_name' do
        include_context 'validator spec setup'
        include_context 'unit instances'

        let(:service_provider_unit) {service_provider_unit_bag}
        let(:unit_name) {service_provider_unit.name}

        actual = nil

        context 'the service_provider_unit is found' do
            before :each do
                allow(command).to receive(:get_service_provider_unit_by_unit_name).and_call_original

                actual = command.send(:get_required_record_service_provider_unit_by_unit_name,
                                      unit_name,
                                      row_index,
                                      column_index,
                                      context)
            end

            it 'calls #get_service_provider_unit_by_unit_name' do
                expect(command).to have_received(:get_service_provider_unit_by_unit_name)
            end

            it 'returns the record' do
                expect(actual).to eq service_provider_unit
            end

            it 'does NOT create an error' do
                expect(command).not_to have_received(:create_error)
            end
        end

        context 'the service_provider_unit is NOT found' do
            before :each do
                allow(command).to receive(:get_service_provider_unit_by_unit_name) {nil}

                actual = command.send(:get_required_record_service_provider_unit_by_unit_name,
                                      unit_name,
                                      row_index,
                                      column_index,
                                      context)
            end

            it 'calls #get_service_provider_unit_by_unit_name' do
                expect(command).to have_received(:get_service_provider_unit_by_unit_name)
            end

            it 'returns nil' do
                expect(actual).to be_nil
            end

            it 'creates an error' do
                error_message = "No service_provider_unit with unit_name #{unit_name.inspect} (column #{column_index}) was found for this restaurant."
                expect(command).to have_received(:create_error).with(row_index,
                                                                     column_index,
                                                                     error_message,
                                                                     context)
            end
        end
    end

    describe '#restrict_service_provider_unit_to_vendor_allowed_order_units' do
        include_context 'validator spec setup'
        include_context 'a vendor'
        include_context 'unit instances'

        actual = nil

        context 'the vendor allows all units' do
            let(:service_provider_unit) {service_provider_unit_bag}

            before :each do
                allow(vendor).to receive(:allowed_order_units) {nil}

                actual = command.send(:restrict_service_provider_unit_to_vendor_allowed_order_units,
                                      service_provider_unit,
                                      vendor,
                                      row_index,
                                      column_index,
                                      context)
            end

            it 'returns true' do
                expect(actual).to be_truthy
            end

            it 'does NOT create an error' do
                expect(command).not_to have_received(:create_error)
            end
        end

        context 'the vendor allows specific units' do
            let(:allowed_order_units) {
                [
                    service_provider_unit_case,
                    service_provider_unit_each
                ]
            }

            before :each do
                allow(vendor).to receive(:allowed_order_units) {allowed_order_units}
            end

            context 'the unit is allowed' do
                let(:service_provider_unit) {service_provider_unit_case}

                before :each do
                    actual = command.send(:restrict_service_provider_unit_to_vendor_allowed_order_units,
                                          service_provider_unit,
                                          vendor,
                                          row_index,
                                          column_index,
                                          context)
                end

                it 'returns true' do
                    expect(actual).to be_truthy
                end

                it 'does NOT create an error' do
                    expect(command).not_to have_received(:create_error)
                end
            end

            context 'the unit is NOT allowed' do
                let(:service_provider_unit) {service_provider_unit_bag}

                before :each do
                    actual = command.send(:restrict_service_provider_unit_to_vendor_allowed_order_units,
                                          service_provider_unit,
                                          vendor,
                                          row_index,
                                          column_index,
                                          context)
                end

                it 'returns false' do
                    expect(actual).to be_falsey
                end

                it 'creates an error' do
                    error_message = "Service_provider_unit #{service_provider_unit.name.inspect} (column #{column_index}) is not a valid order_unit for vendor (#{vendor.name})."
                    expect(command).to have_received(:create_error).with(row_index,
                                                                         column_index,
                                                                         error_message,
                                                                         context)
                end
            end
        end
    end
end

describe 'UseCases::BulkLoad::LoadDataCommand' do
    include_context 'a mock bulk load context'

    let(:command) {UseCases::BulkLoad::LoadDataCommand.new}

    describe '#execute' do
        let(:first_row_index) {0}
        let(:last_row_index) {4}

        before :each do
            allow(command).to receive(:get_first_row_index) {first_row_index}
            allow(command).to receive(:get_last_row_index) {last_row_index}
            allow(command).to receive(:process_row)

            command.execute(context)
        end

        it 'skips the first row' do
            expect(command).not_to have_received(:process_row).with(first_row_index, context)
        end

        it 'calls #verify_row on all other rows' do
            expect(command).to have_received(:process_row).with(1, context)
            expect(command).to have_received(:process_row).with(2, context)
            expect(command).to have_received(:process_row).with(3, context)
            expect(command).to have_received(:process_row).with(last_row_index, context)
            expect(command).to have_received(:process_row).exactly(last_row_index).times
        end

        it 'sets :total_items_count' do
            expect(context.bulk_load_inventory_items_job.total_items_count).to eq 4
        end
    end
end
