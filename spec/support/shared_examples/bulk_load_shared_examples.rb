shared_examples 'an accessed value' do
    it 'loads the value' do
        expect(command).to have_received(:get_value_for_cell).with(row_index, column_index, context)
    end
end

shared_examples 'an ignored value' do
    it 'does NOT load the value' do
        expect(command).not_to have_received(:get_value_for_cell).with(row_index, column_index, context)
    end
end

shared_examples 'a required value' do
    it 'invokes #get_required_parameter' do
        expect(command).to have_received(:get_required_parameter).with(row_index, column_index, context)
    end

    it 'does NOT invoke #get_optional_parameter' do
        expect(command).not_to have_received(:get_optional_parameter).with(row_index, column_index, context)
    end
end

shared_examples 'an optional value' do
    it 'does NOT invoke #get_required_parameter' do
        expect(command).not_to have_received(:get_required_parameter).with(row_index, column_index, context)
    end

    it 'invokes #get_optional_parameter' do
        expect(command).to have_received(:get_optional_parameter).with(row_index, column_index, context)
    end
end

shared_examples 'a required blank cell' do
    it 'invokes #require_blank_cell' do
        expect(command).to have_received(:require_blank_cell).with(row_index, column_index, context, explanation)
    end
end

shared_examples 'a type-restricted value: boolean' do
    it 'requires the the type boolean' do
        expect(command).to have_received(:restrict_type_to_boolean).with(anything, row_index, column_index, context)
    end
end

shared_examples 'a type-restricted value: date' do
    it 'requires the the type date' do
        expect(command).to have_received(:restrict_type_to_date).with(anything, row_index, column_index, context)
    end
end

shared_examples 'a type-restricted value: integer' do
    it 'requires the the type integer' do
        expect(command).to have_received(:restrict_type_to_integer).with(anything, row_index, column_index, context)
    end
end

shared_examples 'a type-restricted value: decimal' do
    it 'requires the the type decimal' do
        expect(command).to have_received(:restrict_type_to_decimal).with(anything, row_index, column_index, context)
    end
end

shared_examples 'a value-restricted quantity: non-negative' do
    it 'requires the the value be non-negative' do
        expect(command).to have_received(:restrict_value_non_negative).with(anything, row_index, column_index, context)
    end
end

shared_examples 'a check for an existing record: inventory_item, by id' do
    it 'checks that the inventory_item exists' do
        expect(command).to have_received(:get_required_record_inventory_item_by_id).with(anything, row_index, column_index, context)
    end
end

shared_examples 'a check for an existing record: vendor, by key' do
    it 'checks that the vendor exists' do
        expect(command).to have_received(:get_required_record_vendor_by_key).with(anything, row_index, column_index, context)
    end
end

shared_examples 'a check for an existing record: accounting_category, by name' do
    it 'checks that the accounting_category exists' do
        expect(command).to have_received(:get_required_record_accounting_category_by_name).with(anything, row_index, column_index, context)
    end
end

shared_examples 'a check for an existing record: service_provider_unit, by unit_name' do
    it 'checks that the service_provider_unit exists' do
        expect(command).to have_received(:get_required_record_service_provider_unit_by_unit_name).with(anything, row_index, column_index, context)
    end
end

shared_examples 'a check for an allowed_order_unit' do
    it 'checks that the service_provider_unit is allowed foir the vendor' do
        expect(command).to have_received(:restrict_service_provider_unit_to_vendor_allowed_order_units).with(kind_of(ServiceProviderUnit), kind_of(Vendor), row_index, column_index, context)
    end
end
