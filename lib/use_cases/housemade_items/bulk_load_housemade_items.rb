require 'use_cases/bulk_load/bulk_load_csv_job'

module UseCases
    module HousemadeItems

        module HousemadeItemsColumns
            ITEM_NAME_COLUMN     = 1
            ITEM_UNIT_COLUMN     = 2
            REST_ITEM_ID_COLUMN  = 3
            ITEM_DESC_COLUMN     = 4
            ACCT_CATEGORY_COLUMN = 5
            RECIPE_COST_COLUMN   = 6
            RECIPE_DATE_COLUMN   = 7

            def build_column_names_array
                column_names = []
                column_names[ITEM_NAME_COLUMN] = 'Item name'
                column_names[ITEM_UNIT_COLUMN] = 'Item unit'
                column_names[REST_ITEM_ID_COLUMN] = 'Restaurant identifier'
                column_names[ITEM_DESC_COLUMN] = 'Item description'
                column_names[ACCT_CATEGORY_COLUMN] = 'Accounting category'
                column_names[RECIPE_COST_COLUMN] = 'Recipe cost per unit'
                column_names[RECIPE_DATE_COLUMN] = 'Recipe cost date'
                column_names
            end
        end

        module VerifyHousemadeItemsDataHelper
            include HousemadeItemsColumns

            def verify_row(row_index, context)
                column_index = ITEM_NAME_COLUMN
                parameter_value = get_required_parameter(row_index, column_index, context)

                column_index = ITEM_UNIT_COLUMN
                parameter_value = get_required_parameter(row_index, column_index, context)
                get_required_record_service_provider_unit_by_unit_name(parameter_value, row_index, column_index, context) unless parameter_value.nil?

                column_index = REST_ITEM_ID_COLUMN
                parameter_value = get_optional_parameter(row_index, column_index, context)

                column_index = ITEM_DESC_COLUMN
                parameter_value = get_optional_parameter(row_index, column_index, context)

                column_index = ACCT_CATEGORY_COLUMN
                parameter_value = get_required_parameter(row_index, column_index, context)
                get_required_record_accounting_category_by_name(parameter_value, row_index, column_index, context) unless parameter_value.nil?

                column_index = RECIPE_COST_COLUMN
                parameter_value = get_optional_parameter(row_index, column_index, context)
                restrict_type_to_decimal(parameter_value, row_index, column_index, context) unless parameter_value.nil?

                column_index = RECIPE_DATE_COLUMN
                parameter_value = get_optional_parameter(row_index, column_index, context)
                restrict_type_to_date(parameter_value, row_index, column_index, context) unless parameter_value.nil?
            end
        end

        module LoadHousemadeItemsDataHelper
            include HousemadeItemsColumns

            def process_row(row_index, context)
                service_provider = context.service_provider
                bulk_load_inventory_items_job = context.bulk_load_inventory_items_job

                item_name                  = get_value_for_cell(row_index, ITEM_NAME_COLUMN, context)
                item_unit_name             = get_value_for_cell(row_index, ITEM_UNIT_COLUMN, context)
                restaurant_item_identifier = get_value_for_cell(row_index, REST_ITEM_ID_COLUMN, context)
                item_description           = get_value_for_cell(row_index, ITEM_DESC_COLUMN, context)
                category_name              = get_value_for_cell(row_index, ACCT_CATEGORY_COLUMN, context)
                recipe_cost_per_unit       = get_value_for_cell(row_index, RECIPE_COST_COLUMN, context)
                recipe_cost_date           = get_value_for_cell(row_index, RECIPE_DATE_COLUMN, context)

                unless item_description
                    item_description = ''
                end

                unless recipe_cost_per_unit
                    recipe_cost_per_unit = 0
                end

                recipe_cost_date = coerce_to_date(recipe_cost_date)

                recipe_cost_timestamp = nil
                if recipe_cost_date
                    recipe_cost_timestamp = service_provider.beginning_of_day_local(recipe_cost_date)
                end

                if item_name && item_description && category_name
                    accounting_category = get_accounting_category_by_name(category_name, context)
                    item_unit = get_service_provider_unit_by_unit_name(item_unit_name, context)

                    housemade_item = InventoryItem.
                        where(name: item_name, service_provider_id: service_provider.id).
                        first

                    unless housemade_item
                        housemade_item = InventoryItem.new(name: item_name,
                                                           description: item_description,
                                                           restaurant_identifier: restaurant_item_identifier)

                        housemade_item.type                 = InventoryItem::TYPE_HOUSEMADE
                        housemade_item.service_provider     = service_provider
                        housemade_item.accounting_category  = accounting_category
                        housemade_item.item_unit            = item_unit
                        housemade_item.recipe_cost_per_unit = recipe_cost_per_unit
                        housemade_item.recipe_cost_timestamp = recipe_cost_timestamp
                        housemade_item.save!

                        Rails.logger.info "Inventory item #{housemade_item.id} created!"

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
