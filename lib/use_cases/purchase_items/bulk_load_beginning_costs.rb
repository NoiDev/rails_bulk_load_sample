require 'use_cases/bulk_load/bulk_load_csv_job'

module UseCases
    module PurchaseItems

        module BeginningCostsColumns
            ITEM_ID_COLUMN        = 1
            ITEM_NAME_COLUMN      = 2
            ITEM_UNIT_COLUMN      = 3
            REST_ITEM_ID_COLUMN   = 4
            ITEM_DESC_COLUMN      = 5
            BEGINNING_COST_COLUMN = 6

            def build_column_names_array
                column_names = []
                column_names[ITEM_ID_COLUMN] = 'Purchase item id'
                column_names[ITEM_NAME_COLUMN] = 'Item name'
                column_names[ITEM_UNIT_COLUMN] = 'Item unit'
                column_names[REST_ITEM_ID_COLUMN] = 'Restaurant identifier'
                column_names[ITEM_DESC_COLUMN] = 'Item description'
                column_names[BEGINNING_COST_COLUMN] = 'Beginning cost'
                column_names
            end
        end

        module VerifyBeginningCostsDataHelper
            include BeginningCostsColumns

            def verify_row(row_index, context)
                column_index = ITEM_ID_COLUMN
                parameter_value = get_required_parameter(row_index, column_index, context)
                is_integer = restrict_type_to_integer(parameter_value, row_index, column_index, context) unless parameter_value.nil?
                get_required_record_inventory_item_by_id(parameter_value, row_index, column_index, context) if is_integer

                column_index = ITEM_NAME_COLUMN
                # Note: Values in the Item Name column are ignored.

                column_index = ITEM_UNIT_COLUMN
                parameter_value = get_required_parameter(row_index, column_index, context)
                get_required_record_service_provider_unit_by_unit_name(parameter_value, row_index, column_index, context) unless parameter_value.nil?

                column_index = REST_ITEM_ID_COLUMN
                # Note: Values in the Restaurant Item Identifier column are ignored.

                column_index = ITEM_DESC_COLUMN
                # Note: Values in the Item Description column are ignored.

                column_index = BEGINNING_COST_COLUMN
                parameter_value = get_required_parameter(row_index, column_index, context)
                is_decimal = restrict_type_to_decimal(parameter_value, row_index, column_index, context) unless parameter_value.nil?
                restrict_value_non_negative(parameter_value, row_index, column_index, context) unless parameter_value.nil?
            end
        end

        module LoadBeginningCostsDataHelper
            include BeginningCostsColumns

            def process_row(row_index, context)
                bulk_load_inventory_items_job = context.bulk_load_inventory_items_job
                
                inventory_item_id = get_value_for_cell(row_index, ITEM_ID_COLUMN, context)
                beginning_cost = get_value_for_cell(row_index, BEGINNING_COST_COLUMN, context)
                
                if inventory_item_id && beginning_cost
                    purchased_item = get_inventory_item_by_id(inventory_item_id,
                                                              context)

                    if purchased_item
                        purchased_item.starting_average_cost = beginning_cost
                        purchased_item.save!

                        Rails.logger.info "Inventory item #{purchased_item.id} beginning cost updated!"

                        bulk_load_inventory_items_job.added_items_count += 1
                        bulk_load_inventory_items_job.save!
                    else
                        bulk_load_inventory_items_job.skipped_items_count += 1
                        bulk_load_inventory_items_job.save!
                    end
                end
            end
        end

    end
end
