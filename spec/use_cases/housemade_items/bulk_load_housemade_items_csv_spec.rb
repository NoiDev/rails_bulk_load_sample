require 'rails_helper'

describe 'UseCase: BulkLoadHousemadeItemsCsv' do
    include_context 'a bulk load house-made item scenario'

    let(:use_case) { UseCases::HousemadeItems::BulkLoadHousemadeItemsCsv.new }

    context 'verify spreadsheet only' do
        context 'successful outcome' do
            let(:spreadsheet_file) { File.new('spec/use_cases/housemade_items/spreadsheets/bulk-load-housemade-items--normal.csv') }
            let(:bulk_load_inventory_items_job) {
                job = create_bulk_load_inventory_items_job(spreadsheet_file.read { |io| io.data }, true)
                job.user = current_user
                job.save!
                job
            }

            let!(:use_case_execution_parameters) {
                {
                    user_id: current_user.id,
                    service_provider_id: restaurant.id,
                    bulk_load_inventory_items_job_id: bulk_load_inventory_items_job.id,
                    verify_spreadsheet_only: bulk_load_inventory_items_job.verify_only?
                }
            }
            let!(:outcome) { use_case.execute use_case_execution_parameters }

            it 'outcome will be successful' do
                expect(outcome.success?).to be true
            end

            it 'will not create any new inventory items' do
                expect(InventoryItem.where(service_provider_id: restaurant.id).count).to eq 0
            end

            it 'will not create any new service provider expense categories' do
                expect(AccountingCategory.where(service_provider_id: restaurant.id).count).to eq 2
            end
        end

        context 'failure outcome' do
            let(:spreadsheet_file) { File.new('spec/use_cases/housemade_items/spreadsheets/bulk-load-housemade-items--missing-fields.csv') }
            let(:bulk_load_inventory_items_job) {
                job = create_bulk_load_inventory_items_job(spreadsheet_file.read { |io| io.data }, true)
                job.user = current_user
                job.save!
                job
            }
            let!(:use_case_execution_parameters) {
                {
                    user_id: current_user.id,
                    service_provider_id: restaurant.id,
                    bulk_load_inventory_items_job_id: bulk_load_inventory_items_job.id,
                    verify_spreadsheet_only: bulk_load_inventory_items_job.verify_only?
                }
            }

            it 'will create job error objects' do
                begin
                    use_case.execute use_case_execution_parameters
                rescue RuntimeError
                    expect(BulkLoadInventoryItemsJobError.
                        where(bulk_load_inventory_items_job_id: bulk_load_inventory_items_job.id).count).to eq 3
                end
            end
        end
    end

    context 'verify and load spreadsheet contents' do
        let(:spreadsheet_file) { File.new('spec/use_cases/housemade_items/spreadsheets/bulk-load-housemade-items--normal.csv') }
        let(:bulk_load_inventory_items_job) {
            job = create_bulk_load_inventory_items_job(spreadsheet_file.read { |io| io.data })
            job.user = current_user
            job.save!
            job
        }

        context 'successful outcome' do
            let!(:use_case_execution_parameters) {
                {
                    user_id: current_user.id,
                    service_provider_id: restaurant.id,
                    bulk_load_inventory_items_job_id: bulk_load_inventory_items_job.id,
                    verify_spreadsheet_only: bulk_load_inventory_items_job.verify_only?
                }
            }
            let!(:outcome) { use_case.execute use_case_execution_parameters }

            let(:ciabatta_name)  { 'Bread, Ciabatta' }
            let(:reduction_name) { 'Red Wine Reduction Base' }
            let(:ciabatta_inventory_item)  { InventoryItem.where(name: ciabatta_name ).first }
            let(:reduction_inventory_item) { InventoryItem.where(name: reduction_name).first }

            it 'outcome will be successful' do
                expect(outcome.success?).to be true
            end

            context 'inventory items' do
                context 'ciabatta item' do
                    it 'is created' do
                        expect(InventoryItem.where(name: ciabatta_name).count).to eq 1
                    end

                    it 'has the expense category set' do
                        expect(ciabatta_inventory_item.accounting_category).not_to be_nil
                    end

                    it 'has the restaurant identifier set' do
                        expect(ciabatta_inventory_item.restaurant_identifier).to be_nil
                    end

                    it 'the item unit is set appropriately' do
                        expect(ciabatta_inventory_item.item_unit.unit.name).to eq 'Each'
                    end

                    it 'the recipe_cost_per_unit property is set appropriately' do
                        expect(ciabatta_inventory_item.recipe_cost_per_unit).to eq 0
                    end

                    it 'the recipe_cost_timestamp property is set appropriately' do
                        expect(ciabatta_inventory_item.recipe_cost_timestamp).to be_nil
                    end
                end

                context 'wine reduction item' do
                    it 'is created' do
                        expect(InventoryItem.where(name: reduction_name).count).to eq 1
                    end

                    it 'has the expense category set' do
                        expect(reduction_inventory_item.accounting_category).not_to be_nil
                    end

                    it 'has the restaurant identifier set' do
                        expect(reduction_inventory_item.restaurant_identifier).to eq '924'
                    end

                    it 'the item unit is set appropriately' do
                        expect(reduction_inventory_item.item_unit.unit.name).to eq 'Cup'
                    end

                    it 'the recipe_cost_per_unit property is set appropriately' do
                        expect(reduction_inventory_item.recipe_cost_per_unit).to eq 2.71
                    end

                    it 'the recipe_cost_timestamp property is set appropriately' do
                        recipe_cost_date =  Date.strptime('4/30/17', '%m/%d/%y')
                        recipe_cost_timestamp = restaurant.beginning_of_day_local(recipe_cost_date)
                        expect(reduction_inventory_item.recipe_cost_timestamp).to eq recipe_cost_timestamp
                    end
                end
            end

            it 'creates a new expense category' do
                matching_expense_categories = AccountingCategory.where(expense_name: 'Bakery').load
                expect(matching_expense_categories.length).to eq 1
            end

            it 'reuses existing expense category' do
                new_inventory_item = InventoryItem.where(name: reduction_name).first
                expect(new_inventory_item.accounting_category).to eq grocery_accounting_category
            end
        end

        context 'failure outcome' do
            context 'missing user_id' do
                let!(:outcome) { use_case.execute({bulk_load_inventory_items_job_id: bulk_load_inventory_items_job.id}) }

                it 'outcome will not be successful' do
                    expect(outcome.success?).to be false
                end
            end

            context 'missing bulk_load_inventory_items_job_id' do
                let!(:outcome) { use_case.execute({user_id: current_user.id}) }

                it 'outcome will not be successful' do
                    expect(outcome.success?).to be false
                end
            end
        end
    end

    private

    def create_bulk_load_inventory_items_job(contents, verify_only=false)
        BulkLoadInventoryItemsJob.new(file_contents: contents,
                                      content_type: BulkLoadInventoryItemsJob::CONTENT_TYPE_CSV,
                                      verify_only: verify_only)
    end
end
