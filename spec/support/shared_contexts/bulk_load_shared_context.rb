shared_context 'core domain model for a bulk_load_inventory_items_job' do
    include_context 'a current user'
end

shared_context 'a bulk_load_inventory_items_job' do
    include_context 'core domain model for a bulk_load_inventory_items_job'

    let(:bulk_load_inventory_items_job) {
        create :bulk_load_inventory_items_job,
            user: current_user
    }
end

shared_context 'verify command helper method mocks' do
    before :each do
        allow(command).to receive(:get_value_for_cell).and_call_original
        allow(command).to receive(:get_required_parameter).and_call_original
        allow(command).to receive(:get_optional_parameter).and_call_original
        allow(command).to receive(:require_blank_cell).and_call_original

        allow(command).to receive(:restrict_type_to_boolean).and_call_original
        allow(command).to receive(:restrict_type_to_date).and_call_original
        allow(command).to receive(:restrict_type_to_integer).and_call_original
        allow(command).to receive(:restrict_type_to_decimal).and_call_original

        allow(command).to receive(:restrict_value_non_negative).and_call_original

        allow(command).to receive(:get_required_record_inventory_item_by_id).and_call_original
        allow(command).to receive(:get_required_record_vendor_by_key).and_call_original
        allow(command).to receive(:get_required_record_accounting_category_by_name).and_call_original
        allow(command).to receive(:get_required_record_service_provider_unit_by_unit_name).and_call_original

        allow(command).to receive(:restrict_service_provider_unit_to_vendor_allowed_order_units).and_call_original
    end
end

shared_context 'load command helper method mocks' do
    before :each do
        allow(command).to receive(:get_value_for_cell).and_call_original

        allow(command).to receive(:coerce_to_boolean).and_call_original
        allow(command).to receive(:coerce_to_date).and_call_original

        allow(command).to receive(:get_inventory_item_by_id).and_call_original
        allow(command).to receive(:get_vendor_by_key).and_call_original
        allow(command).to receive(:get_accounting_category_by_name).and_call_original
        allow(command).to receive(:get_service_provider_unit_by_unit_name).and_call_original
    end
end

shared_context 'a mock bulk load context' do
    include_context 'a bulk_load_inventory_items_job'

    let(:context) {
        context_hash = {
            bulk_load_inventory_items_job: bulk_load_inventory_items_job,
            service_provider: restaurant,
            user: current_user
        }
        OpenStruct.new(context_hash)
    }
end

shared_context 'a bulk load scenario' do
    include_context 'core domain model for a bulk_load_inventory_items_job'

    # REDACTED
end

shared_context 'a bulk load beginning cost scenario' do
    include_context 'core domain model for a bulk_load_inventory_items_job'

    # REDACTED
end

shared_context 'a bulk load house-made item scenario' do
    include_context 'core domain model for a bulk_load_inventory_items_job'

    # REDACTED
end
