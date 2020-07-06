require 'virtus'
require 'spreadsheet'

module UseCases
    module BulkLoad

        module TypeHelpers
            TRUE_STRINGS  = ['true', 'yes', 't', 'y']
            FALSE_STRINGS = ['false', 'no', 'f', 'n']


            # Low-Level Types

            def coerce_to_boolean(parameter_value)
                resolved_value = nil

                if parameter_value.is_a?(TrueClass) || parameter_value.is_a?(FalseClass)
                    resolved_value = parameter_value
                elsif parameter_value.is_a?(String)
                    normalized_string = parameter_value.downcase.strip

                    if TRUE_STRINGS.include? normalized_string
                        resolved_value = true
                    elsif FALSE_STRINGS.include? normalized_string
                        resolved_value = false
                    end
                end

                return resolved_value
            end

            def coerce_to_date(parameter_value)
                resolved_value = nil

                if parameter_value.is_a?(Date)
                    resolved_value = parameter_value
                elsif parameter_value.is_a?(String)
                    normalized_string = parameter_value.strip

                    short_date_regex = /^\d{1,2}\/\d{1,2}\/\d{2}$/
                    long_date_regex = /^\d{1,2}\/\d{1,2}\/\d{4}$/
                    iso_date_regex = /^\d{4}-\d{2}-\d{2}$/
                    if normalized_string.match short_date_regex
                        resolved_value = Date.strptime(normalized_string, '%m/%d/%y')
                    elsif normalized_string.match long_date_regex
                        resolved_value = Date.strptime(normalized_string, '%m/%d/%Y')
                    elsif normalized_string.match iso_date_regex
                        resolved_value = Date.strptime(normalized_string, '%Y-%m-%d')
                    end
                end

                return resolved_value
            end


            # Model Queries

            def get_inventory_item_by_id(inventory_item_id, context)
                InventoryItem
                    .by_service_provider_id(context.service_provider.id)
                    .by_id(inventory_item_id)
                    .take
            end

            def get_inventory_item_by_name(name, context)
                InventoryItem
                    .by_service_provider_id(context.service_provider.id)
                    .by_name(name)
                    .take
            end

            def get_vendor_by_key(vendor_key, context)
                Vendor
                    .by_service_provider_id(context.service_provider.id)
                    .by_key_case_insensitive(vendor_key)
                    .take
            end

            def get_accounting_category_by_name(name, context)
                AccountingCategory
                    .by_service_provider_id(context.service_provider.id)
                    .by_name_case_insensitive(name)
                    .take
            end

            def get_service_provider_unit_by_unit_name(unit_name, context)
                ServiceProviderUnit
                    .by_service_provider_id(context.service_provider.id)
                    .by_unit_name_case_insensitive(unit_name)
                    .take
            end
        end

        module DataAccessHelpers
            # Note: Because format-specific data access logic is needed in
            # both the VerifyDataCommand and the LoadDataCommand, it is
            # helpful to define it once in a module like this one and
            # include that module in each command.

            def get_first_row_index(context)
                # Note: Override in the subclass to return the first row index for the
                # given format. This is usually 0 or 1.
            end

            def get_last_row_index(context)
                # Note: Override in the subclass to return the last row index for the
                # given format. This is usually the length or the length less one.
            end

            def get_value_for_cell(row_index, column_index, context)
                # Note: Override in the subclass to provide format-specific
                # logic to extract values from a cell within the data file.
            end
        end

        class BaseInput
            include Virtus.model

            attribute :bulk_load_inventory_items_job_id, Integer
            attribute :user_id, Integer
            attribute :service_provider_id, Integer
            attribute :verify_spreadsheet_only, Boolean

            def user
                @user ||= User.find(@user_id)
            end

            def service_provider
                @service_provider ||= ServiceProvider.find(@service_provider_id)
            end

            def bulk_load_inventory_items_job
                @bulk_load_inventory_items_job ||=
                    BulkLoadInventoryItemsJob.find(@bulk_load_inventory_items_job_id)
            end
        end

        BaseInputValidator = UseCase::Validator.define do
            validates_presence_of :user_id
            validates_presence_of :service_provider_id
            validates_presence_of :bulk_load_inventory_items_job_id
        end

        class StartProcessingJobCommand
            def execute(context)
                context.bulk_load_inventory_items_job.status =
                    BulkLoadInventoryItemsJobStatus::PROCESSING
                context.bulk_load_inventory_items_job.job_started = Time.now
                context.bulk_load_inventory_items_job.save!
                context
            end
        end

        class CompleteProcessingJobCommand
            def execute(context)
                context.bulk_load_inventory_items_job.status =
                    BulkLoadInventoryItemsJobStatus::PROCESSED
                context.bulk_load_inventory_items_job.job_finished = Time.now
                context.bulk_load_inventory_items_job.save!
                context
            end
        end

        class VerifyDataCommand
            include DataAccessHelpers
            include TypeHelpers

            COLUMN_NAME_UNKNOWN = '(unknown)'

            def execute(context)
                items_count = 0

                first_row_index = get_first_row_index(context)
                last_row_index = get_last_row_index(context)

                before_verify_all_rows(context)

                first_row_skipped = false
                (first_row_index..last_row_index).each_with_index do |row_index|
                    unless first_row_skipped
                        first_row_skipped = true
                    else
                        items_count += 1

                        verify_row(row_index, context)
                    end
                end

                after_verify_all_rows(context)

                context.bulk_load_inventory_items_job.total_items_count = items_count
                context.bulk_load_inventory_items_job.save!

                context
            end

            protected

            def before_verify_all_rows(context)
                # Note: Overload in the subclass to do any pre-verification setup.
            end

            def after_verify_all_rows(context)
                # Note: Overload in the subclass to do any post-verification
                # cleanup or validation which spans multiple rows.
            end

            def verify_row(row_index, context)
                # Note: Override in the subclass verify data in a row.
            end

            # Low-Level Helpers

            def create_error(row_index, column_index, error_message, context)
                bulk_load_inventory_items_job = context.bulk_load_inventory_items_job

                error = BulkLoadInventoryItemsJobError.new(spreadsheet_row: row_index,
                                                           spreadsheet_column: column_index,
                                                           description: error_message)
                error.bulk_load_inventory_items_job = bulk_load_inventory_items_job
                error.save!
            end

            def build_column_names_array
                # Overload this array in the subclass to generate the
                # source array for column names.

                [ ]
            end

            def get_name_for_column(column_index)
                if !@column_names
                    @column_names = build_column_names_array
                end

                column_name = @column_names[column_index]

                if !column_name
                    column_name = COLUMN_NAME_UNKNOWN
                end

                column_name
            end

            def get_required_parameter(row_index, column_index, context)
                parameter_value = get_value_for_cell(row_index, column_index, context)

                if parameter_value.nil?
                    parameter_is_present = false

                    parameter_name = get_name_for_column(column_index)
                    error_message = "The \"#{parameter_name}\" (column #{column_index}) is a required data item."
                    create_error(row_index,
                                 column_index,
                                 error_message,
                                 context)
                end

                return parameter_value
            end

            def get_optional_parameter(row_index, column_index, context)
                parameter_value = get_value_for_cell(row_index, column_index, context)

                # Note: Do not generate an error if the value is nil.
                # Compare with #get_required_parameter

                return parameter_value
            end

            def require_blank_cell(row_index, column_index, context, explanation)

                parameter_value = get_value_for_cell(row_index, column_index, context)

                value_is_nil = parameter_value.nil?
                value_is_empty = parameter_value == ''

                cell_is_blank = value_is_nil || value_is_empty

                unless cell_is_blank
                    parameter_name = get_name_for_column(column_index)
                    error_message = "The #{parameter_name} (column #{column_index}) must must be blank."
                    if explanation
                        error_message += " (#{explanation})"
                    end

                    create_error(row_index,
                                 column_index,
                                 error_message,
                                 context)
                end

                return cell_is_blank
            end


            # Primitive Type Validation

            def restrict_type_to_boolean(parameter_value, row_index, column_index, context)
                valid_boolean_found = nil

                coerced_value = coerce_to_boolean(parameter_value)

                if coerced_value.is_a?(TrueClass) || coerced_value.is_a?(FalseClass)
                    valid_boolean_found = true
                else
                    valid_boolean_found = false
                    parameter_name = get_name_for_column(column_index)
                    error_message = "The value #{parameter_value.inspect} for \"#{parameter_name}\" (column #{column_index}) must be a boolean value (true/false, yes/no)."
                    create_error(row_index,
                                 column_index,
                                 error_message,
                                 context)
                end

                return valid_boolean_found
            end

            def restrict_type_to_date(parameter_value, row_index, column_index, context)
                valid_date_found = nil

                coerced_value = coerce_to_date(parameter_value)

                if coerced_value.is_a?(Date)
                    valid_date_found = true
                else
                    valid_date_found = false
                    parameter_name = get_name_for_column(column_index)
                    error_message = "The value #{parameter_value.inspect} for \"#{parameter_name}\" (column #{column_index}) must be a date value (mm/dd/yy, mm/dd/yyyy, yyyy-mm-dd)."
                    create_error(row_index,
                                 column_index,
                                 error_message,
                                 context)
                end

                return valid_date_found
            end

            def restrict_type_to_integer(parameter_value, row_index, column_index, context)
                valid_integer_found = nil

                if parameter_value.is_a?(Numeric)
                    valid_integer_found = true
                elsif parameter_value.is_a?(String)
                    normalized_string = parameter_value.strip

                    integer_regex = /^-?\d+$/
                    if normalized_string.match(integer_regex)
                        valid_integer_found = true
                    else
                        valid_integer_found = false
                    end
                end

                unless valid_integer_found
                    parameter_name = get_name_for_column(column_index)
                    error_message = "The value #{parameter_value.inspect} for \"#{parameter_name}\" (column #{column_index}) must be an integer."
                    create_error(row_index,
                                 column_index,
                                 error_message,
                                 context)
                end

                return valid_integer_found
            end

            def restrict_type_to_decimal(parameter_value, row_index, column_index, context)
                valid_decimal_found = nil

                if parameter_value.is_a?(Numeric)
                    valid_decimal_found = true
                elsif parameter_value.is_a?(String)
                    normalized_string = parameter_value.strip

                    # See: https://stackoverflow.com/questions/36946443/match-regex-with-numeric-value-and-decimal
                    decimal_regex = /^-?(?:\d+(?:\.\d*)?|\.\d+)$/
                    if normalized_string.match(decimal_regex)
                        valid_decimal_found = true
                    else
                        valid_decimal_found = false
                    end
                end

                unless valid_decimal_found
                    parameter_name = get_name_for_column(column_index)
                    error_message = "The value #{parameter_value.inspect} for \"#{parameter_name}\" (column #{column_index}) must be a number."
                    create_error(row_index,
                                 column_index,
                                 error_message,
                                 context)
                end

                return valid_decimal_found
            end


            # Numeric Value Restriction Validations

            def restrict_value_non_negative(parameter_value, row_index, column_index, context)
                value_is_non_negative = parameter_value.to_d >= 0.0

                unless value_is_non_negative
                    parameter_name = get_name_for_column(column_index)
                    error_message = "The value #{parameter_value.inspect} for \"#{parameter_name}\" (column #{column_index}) cannot be negative."
                    create_error(row_index,
                                 column_index,
                                 error_message,
                                 context)
                end

                value_is_non_negative
            end


            # Model Validation

            def get_required_record_inventory_item_by_id(inventory_item_id, row_index, column_index, context)
                inventory_item = get_inventory_item_by_id(inventory_item_id, context)

                if inventory_item.nil?
                    error_message = "No inventory_item with ID ##{inventory_item_id.inspect} (column #{column_index}) was found for this restaurant."
                    create_error(row_index,
                                 column_index,
                                 error_message,
                                 context)
                end

                inventory_item
            end

            def get_required_record_vendor_by_key(vendor_key, row_index, column_index, context)
                vendor = get_vendor_by_key(vendor_key, context)

                if vendor.nil?
                    error_message = "No vendor with key #{vendor_key.inspect} (column #{column_index}) was found for this restaurant."
                    create_error(row_index,
                                 column_index,
                                 error_message,
                                 context)
                end

                vendor
            end

            def get_required_record_accounting_category_by_name(name, row_index, column_index, context)
                accounting_category = get_accounting_category_by_name(name, context)

                if accounting_category.nil?
                    error_message = "No accounting_category with name #{name.inspect} (column #{column_index}) was found for this restaurant."
                    create_error(row_index,
                                 column_index,
                                 error_message,
                                 context)
                end

                accounting_category
            end

            def get_required_record_service_provider_unit_by_unit_name(unit_name, row_index, column_index, context)
                service_provider_unit = get_service_provider_unit_by_unit_name(unit_name, context)

                if service_provider_unit.nil?
                    error_message = "No service_provider_unit with unit_name #{unit_name.inspect} (column #{column_index}) was found for this restaurant."
                    create_error(row_index,
                                 column_index,
                                 error_message,
                                 context)
                end

                service_provider_unit
            end

            def restrict_service_provider_unit_to_vendor_allowed_order_units(service_provider_unit, vendor, row_index, column_index, context)
                allowed_order_units = vendor.allowed_order_units

                unit_allowed = nil

                if allowed_order_units.nil?
                    unit_allowed = true
                else
                    unit_allowed = allowed_order_units.include? service_provider_unit
                end

                unless unit_allowed
                    error_message = "Service_provider_unit #{service_provider_unit.name.inspect} (column #{column_index}) is not a valid order_unit for vendor (#{vendor.name})."
                    create_error(row_index,
                                 column_index,
                                 error_message,
                                 context)
                end

                unit_allowed
            end
        end

        class LoadDataCommand
            include DataAccessHelpers
            include TypeHelpers

            def execute(context)
                skip_load   = context.verify_spreadsheet_only
                skip_load ||= context.bulk_load_inventory_items_job.has_errors?

                unless skip_load
                    items_count = 0

                    first_row_index = get_first_row_index(context)
                    last_row_index = get_last_row_index(context)

                    first_row_skipped = false
                    (first_row_index..last_row_index).each_with_index do |row_index|
                        unless first_row_skipped
                            first_row_skipped = true
                        else
                            items_count += 1
                            process_row(row_index, context)
                        end
                    end

                    context.bulk_load_inventory_items_job.total_items_count = items_count
                    context.bulk_load_inventory_items_job.save!
                end

                context
            end

            protected

            def process_row(row_index, context)
                # Note: Override in the subclass load data from a row.
            end

        end

        class LoadProcess
            include UseCase

            def get_input_class
                UseCases::BulkLoad::BaseInput
            end

            def verify_data_step
                UseCases::BulkLoad::VerifyDataCommand.new
            end

            def load_data_step
                UseCases::BulkLoad::LoadDataCommand.new
            end

            def initialize
                input_class(get_input_class)
                step UseCases::BulkLoad::StartProcessingJobCommand.new,
                    validator: UseCases::BulkLoad::BaseInputValidator
                step verify_data_step
                step load_data_step
                step UseCases::BulkLoad::CompleteProcessingJobCommand.new
            end
        end
    end
end
