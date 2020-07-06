require 'rails_helper'

describe BulkLoadInventoryItemsJob do
    it { should allow_mass_assignment_of(:file_contents) }
    it { should allow_mass_assignment_of(:status) }
    it { should allow_mass_assignment_of(:job_started) }
    it { should allow_mass_assignment_of(:job_finished) }
    it { should allow_mass_assignment_of(:verify_only) }
    it { should allow_mass_assignment_of(:total_items_count) }
    it { should allow_mass_assignment_of(:added_items_count) }
    it { should allow_mass_assignment_of(:skipped_items_count) }

    it { should belong_to(:user) }
    it { should have_many(:bulk_load_inventory_items_job_errors) }

    describe '#has_errors?' do
        include_context 'a current user'

        let!(:job) { FactoryBot.create :bulk_load_inventory_items_job, user: current_user }

        context 'when errors are associated with the job' do
            let!(:job_error) { FactoryBot.create :bulk_load_inventory_items_job_error,
                                                  bulk_load_inventory_items_job: job }
            it 'should return true' do
                expect(job.has_errors?).to be_truthy
            end
        end

        context 'when errors are not associated with the job' do
            it 'should return false' do
                expect(job.has_errors?).to be_falsey
            end
        end
    end

    describe '#is_excel_file?' do
        include_context 'a current user'

        context 'when job has an Excel file content type' do
            let!(:job) { FactoryBot.create :bulk_load_inventory_items_job, user: current_user,
                                            content_type: BulkLoadInventoryItemsJob::CONTENT_TYPE_EXCEL }
            it 'should return true' do
                expect(job.is_excel_file?).to be_truthy
            end
        end

        context 'when job has a CSV file content type' do
            let!(:job) { FactoryBot.create :bulk_load_inventory_items_job, user: current_user,
                                            content_type: BulkLoadInventoryItemsJob::CONTENT_TYPE_CSV }
            it 'should return false' do
                expect(job.is_excel_file?).to be_falsey
            end
        end
    end

    describe '#is_csv_file?' do
        include_context 'a current user'

        context 'when job has an Excel file content type' do
            let!(:job) { FactoryBot.create :bulk_load_inventory_items_job, user: current_user,
                                            content_type: BulkLoadInventoryItemsJob::CONTENT_TYPE_EXCEL }
            it 'should return false' do
                expect(job.is_csv_file?).to be_falsey
            end
        end

        context 'when job has a CSV file content type' do
            let!(:job) { FactoryBot.create :bulk_load_inventory_items_job, user: current_user,
                                            content_type: BulkLoadInventoryItemsJob::CONTENT_TYPE_CSV }
            it 'should return true' do
                expect(job.is_csv_file?).to be_truthy
            end
        end
    end
end
