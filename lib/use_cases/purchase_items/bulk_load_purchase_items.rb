require 'use_cases/bulk_load/bulk_load_job'

module UseCases
    module PurchaseItems

        module PurchaseItemsColumns
            ITEM_NAME_COLUMN      = 1
            ITEM_UNIT_COLUMN      = 2
            REST_ITEM_ID_COLUMN   = 3
            ITEM_DESC_COLUMN      = 4
            ACCT_CATEGORY_COLUMN  = 5
            TAXABLE_COLUMN        = 6
            ORDERING_COLUMN       = 7
            INVENTORY_COLUMN      = 8
            BEGINNING_COST_COLUMN = 9
            PRIMARY_VENDOR_COLUMN = 10
            VENDOR_KEY_COLUMN     = 11
            VENDOR_ITEM_ID_COLUMN = 12
            ORDER_UNIT_COLUMN     = 13
            PACK_VALUE_COLUMN     = 14

            def build_column_names_array
                column_names = []
                column_names[ITEM_NAME_COLUMN] = 'Item name'
                column_names[ITEM_UNIT_COLUMN] = 'Item unit'
                column_names[REST_ITEM_ID_COLUMN] = 'Restaurant identifier'
                column_names[ITEM_DESC_COLUMN] = 'Item description'
                column_names[ACCT_CATEGORY_COLUMN] = 'Accounting category'
                column_names[TAXABLE_COLUMN] = 'Taxable'
                column_names[ORDERING_COLUMN] = 'Ordering'
                column_names[INVENTORY_COLUMN] = 'Inventory'
                column_names[BEGINNING_COST_COLUMN] = 'Begining inventory cost'
                column_names[PRIMARY_VENDOR_COLUMN] = 'Primary vendor flag'
                column_names[VENDOR_KEY_COLUMN] = 'Vendor key'
                column_names[VENDOR_ITEM_ID_COLUMN] = 'Vendor identifier'
                column_names[ORDER_UNIT_COLUMN] = 'Order unit'
                column_names[PACK_VALUE_COLUMN] = 'Pack value'
                column_names
            end
        end

        module VerifyPurchaseItemsDataHelper
            include PurchaseItemsColumns

            def verify_row(row_index, context)
                column_index = ITEM_NAME_COLUMN
                parameter_value = get_required_parameter(row_index, column_index, context)

                inventory_item_name = parameter_value
                inventory_item = get_inventory_item_by_name(inventory_item_name, context)
                inventory_item_is_new = inventory_item.nil?

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

                column_index = TAXABLE_COLUMN
                parameter_value = get_required_parameter(row_index, column_index, context)
                restrict_type_to_boolean(parameter_value, row_index, column_index, context) unless parameter_value.nil?

                column_index = ORDERING_COLUMN
                parameter_value = get_required_parameter(row_index, column_index, context)
                restrict_type_to_boolean(parameter_value, row_index, column_index, context) unless parameter_value.nil?

                item_is_used_for_ordering = coerce_to_boolean(parameter_value)

                column_index = INVENTORY_COLUMN
                parameter_value = get_required_parameter(row_index, column_index, context)
                restrict_type_to_boolean(parameter_value, row_index, column_index, context) unless parameter_value.nil?

                column_index = BEGINNING_COST_COLUMN
                parameter_value = get_optional_parameter(row_index, column_index, context)
                restrict_type_to_decimal(parameter_value, row_index, column_index, context) unless parameter_value.nil?
                restrict_value_non_negative(parameter_value, row_index, column_index, context) unless parameter_value.nil?


                if item_is_used_for_ordering
                    if inventory_item_is_new
                        log_new_ordering_inventory_item(inventory_item_name,
                                                        row_index)
                    end

                    column_index = PRIMARY_VENDOR_COLUMN
                    parameter_value = get_required_parameter(row_index, column_index, context)
                    restrict_type_to_boolean(parameter_value, row_index, column_index, context) unless parameter_value.nil?

                    is_primary_vendor = coerce_to_boolean(parameter_value)

                    if is_primary_vendor && inventory_item_is_new
                        log_primary_vendor_for_new_ordering_inventory_item(inventory_item_name)
                    end

                    column_index = VENDOR_KEY_COLUMN
                    parameter_value = get_required_parameter(row_index, column_index, context)
                    vendor = get_required_record_vendor_by_key(
                        parameter_value, row_index, column_index, context) unless parameter_value.nil?

                    column_index = VENDOR_ITEM_ID_COLUMN
                    parameter_value = get_optional_parameter(row_index, column_index, context)

                    column_index = ORDER_UNIT_COLUMN
                    parameter_value = get_required_parameter(row_index, column_index, context)
                    order_unit = get_required_record_service_provider_unit_by_unit_name(
                        parameter_value, row_index, column_index, context) unless parameter_value.nil?
                    restrict_service_provider_unit_to_vendor_allowed_order_units(
                        order_unit, vendor, row_index, column_index, context) unless (vendor.nil? || order_unit.nil?)

                    column_index = PACK_VALUE_COLUMN
                    parameter_value = get_required_parameter(row_index, column_index, context)
                    is_decimal = restrict_type_to_decimal(parameter_value, row_index, column_index, context) unless parameter_value.nil?
                    restrict_value_non_negative(parameter_value, row_index, column_index, context) if !parameter_value.nil? && is_decimal
                else
                    explanation = 'Item is not used for ordering.'

                    column_index = PRIMARY_VENDOR_COLUMN
                    require_blank_cell(row_index, column_index, context, explanation)

                    column_index = VENDOR_KEY_COLUMN
                    require_blank_cell(row_index, column_index, context, explanation)

                    column_index = VENDOR_ITEM_ID_COLUMN
                    require_blank_cell(row_index, column_index, context, explanation)

                    column_index = ORDER_UNIT_COLUMN
                    require_blank_cell(row_index, column_index, context, explanation)

                    column_index = PACK_VALUE_COLUMN
                    require_blank_cell(row_index, column_index, context, explanation)
                end
            end

            def before_verify_all_rows(context)
                @inventory_item_primary_vendors = {}
            end

            def after_verify_all_rows(context)
                each_new_ordering_inventory_item_must_have_a_primary_vendor(context)
            end

            def log_new_ordering_inventory_item(inventory_item_name, row_index)
                if !@inventory_item_primary_vendors[inventory_item_name]
                    @inventory_item_primary_vendors[inventory_item_name] = {
                        row_index: row_index,
                        primary_vendor_set: false
                    }
                end
            end

            def log_primary_vendor_for_new_ordering_inventory_item(inventory_item_name)
                @inventory_item_primary_vendors[inventory_item_name][:primary_vendor_set] = true
            end

            def each_new_ordering_inventory_item_must_have_a_primary_vendor(context)
                @inventory_item_primary_vendors.each do |inventory_item_name, entry|
                    unless entry[:primary_vendor_set]
                        row_index = entry[:row_index]
                        column_index = PRIMARY_VENDOR_COLUMN
                        error_message = "New inventory item #{inventory_item_name.inspect} introduced on row ##{row_index} is flagged for Ordering (column ##{ORDERING_COLUMN}) but does not have a vendor flagged as Primary (column ##{PRIMARY_VENDOR_COLUMN})."
                        create_error(row_index,
                                     column_index,
                                     error_message,
                                     context)
                    end
                end
            end
        end

        module LoadPurchaseItemsDataHelper
            include PurchaseItemsColumns

            def process_row(row_index, context)
                user = context.user
                service_provider = context.service_provider
                bulk_load_inventory_items_job = context.bulk_load_inventory_items_job

                item_name                  = get_value_for_cell(row_index, ITEM_NAME_COLUMN, context)
                item_unit_name             = get_value_for_cell(row_index, ITEM_UNIT_COLUMN, context)
                restaurant_item_identifier = get_value_for_cell(row_index, REST_ITEM_ID_COLUMN, context)
                item_description           = get_value_for_cell(row_index, ITEM_DESC_COLUMN, context)
                category_name              = get_value_for_cell(row_index, ACCT_CATEGORY_COLUMN, context)
                taxable_indicator          = get_value_for_cell(row_index, TAXABLE_COLUMN, context)
                use_on_ordering_indicator  = get_value_for_cell(row_index, ORDERING_COLUMN, context)
                use_on_inventory_indicator = get_value_for_cell(row_index, INVENTORY_COLUMN, context)
                beginning_cost             = get_value_for_cell(row_index, BEGINNING_COST_COLUMN, context)
                is_primary_vendor          = get_value_for_cell(row_index, PRIMARY_VENDOR_COLUMN, context)
                vendor_key                 = get_value_for_cell(row_index, VENDOR_KEY_COLUMN, context)
                vendor_specific_identifier = get_value_for_cell(row_index, VENDOR_ITEM_ID_COLUMN, context)
                order_unit_name            = get_value_for_cell(row_index, ORDER_UNIT_COLUMN, context)
                pack_value                 = get_value_for_cell(row_index, PACK_VALUE_COLUMN, context)

                taxable_indicator          = coerce_to_boolean(taxable_indicator)
                use_on_ordering_indicator  = coerce_to_boolean(use_on_ordering_indicator)
                use_on_inventory_indicator = coerce_to_boolean(use_on_inventory_indicator)
                is_primary_vendor          = coerce_to_boolean(is_primary_vendor)

                if item_name && item_description && category_name
                    accounting_category = get_accounting_category_by_name(category_name, context)

                    item_unit = get_service_provider_unit_by_unit_name(item_unit_name, context)
                    order_unit = get_service_provider_unit_by_unit_name(order_unit_name, context)

                    purchased_item = InventoryItem.
                        where(name: item_name, service_provider_id: service_provider.id).
                        first

                    inventory_item_added = nil
                    unless purchased_item
                        inventory_item_added = true

                        purchased_item = InventoryItem.new(name: item_name,
                                                           description: item_description,
                                                           restaurant_identifier: restaurant_item_identifier)

                        purchased_item.service_provider      = service_provider
                        purchased_item.accounting_category   = accounting_category
                        purchased_item.item_unit             = item_unit
                        purchased_item.taxable               = taxable_indicator
                        purchased_item.ordering              = use_on_ordering_indicator
                        purchased_item.inventory             = use_on_inventory_indicator
                        purchased_item.starting_average_cost = beginning_cost
                        purchased_item.save!

                        Rails.logger.info "Inventory item #{purchased_item.id} created!"
                    end

                    vendor_inventory_item_added = nil
                    vendor = get_vendor_by_key(vendor_key, context)
                    if vendor && use_on_ordering_indicator
                        existing_vendor_inventory_item = VendorInventoryItem
                            .find_unique_vendor_inventory_item(vendor,
                                                               purchased_item,
                                                               vendor_specific_identifier,
                                                               order_unit)

                        unless existing_vendor_inventory_item
                            vendor_inventory_item_added = true

                            vendor_inventory_item = VendorInventoryItem.new

                            vendor_inventory_item.inventory_item = purchased_item
                            vendor_inventory_item.vendor         = vendor
                            vendor_inventory_item.order_unit     = order_unit
                            vendor_inventory_item.pack_value     = pack_value

                            if vendor_inventory_item
                                vendor_inventory_item.vendor_specific_identifier = vendor_specific_identifier
                            end

                            if is_primary_vendor
                                vendor_inventory_item.set_as_primary_vendor
                            end

                            vendor_inventory_item.save!

                            Rails.logger.info "Vendor inventory item #{vendor_inventory_item.id} created!"
                        end
                    end

                    if inventory_item_added || vendor_inventory_item_added
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
