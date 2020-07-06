require 'rails_helper'

describe 'UseCase: BulkLoadBeginningCostsExcel' do
    include_context 'a bulk load beginning cost scenario'

    let(:use_case) { UseCases::PurchaseItems::BulkLoadBeginningCostsExcel.new }

    context 'verify spreadsheet only' do
        context 'successful outcome' do
            let(:spreadsheet_file) { File.new('spec/use_cases/purchase_items/spreadsheets/bulk-load-beginning-costs-no-errors.xlsx') }
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
        end

        context 'failure outcome' do
            let(:spreadsheet_file) { File.new('spec/use_cases/purchase_items/spreadsheets/bulk-load-beginning-costs-has-errors.xlsx') }
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
                        where(bulk_load_inventory_items_job_id: bulk_load_inventory_items_job.id).count).to eq 1
                end
            end
        end
    end

    context 'verify and load spreadsheet contents' do
        let(:spreadsheet_file) { File.new('spec/use_cases/purchase_items/spreadsheets/bulk-load-beginning-costs-no-errors.xlsx') }
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
            let!(:item_with_id_4) { InventoryItem.find_by_id 4 }

            it 'outcome will be successful' do
                expect(outcome.success?).to be true
            end

            it 'updates items starting average cost' do
                expect(item_with_id_4.starting_average_cost).to eq 3.34
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
                                      content_type: BulkLoadInventoryItemsJob::CONTENT_TYPE_EXCEL,
                                      verify_only: verify_only)
    end
end
