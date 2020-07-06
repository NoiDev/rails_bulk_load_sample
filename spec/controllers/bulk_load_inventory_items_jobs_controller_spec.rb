require 'rails_helper'

describe BulkLoadInventoryItemsJobsController do

    describe 'routing', :type => :routing do
        it 'routes get /api/bulk_load_inventory_items_jobs to the bulk_load_inventory_items_jobs index action' do
            expect(get('/api/bulk_load_inventory_items_jobs')).
                to route_to(:action => 'index', :controller => 'bulk_load_inventory_items_jobs')
        end

        it 'routes get /api/bulk_load_inventory_items_jobs/89423 to the bulk_load_inventory_items_jobs show action' do
            expect(get('/api/bulk_load_inventory_items_jobs/89423')).
                to route_to(:action => 'show', :controller => 'bulk_load_inventory_items_jobs', :id => '89423')
        end
    end

    describe 'controller actions' do
        include_context 'a restaurant'

        before :each do
            sign_in current_user if current_user
        end

        describe 'GET #index' do
            let(:params) { {format: 'json'} }

            context 'user is not signed in' do
                let(:current_user) { nil }

                describe 'the response' do
                    it 'status equals 401 (Unauthorized)' do
                        get :index, params
                        expect(response.status).to be Rack::Utils.status_code(:unauthorized)
                    end
                end
            end

            context 'user is signed in' do
                include_context 'a current user'

                let(:file_contents) {
                    File.open('spec/controllers/data/bulk-load-inventory-items-001.xlsx', 'r').read
                }
                let!(:bulk_load_inventory_items_jobs) {
                    create_list(:bulk_load_inventory_items_job,
                                5,
                                user: current_user,
                                file_contents: file_contents)
                }
                let!(:bulk_load_inventory_items_job_errors) {
                    create(:bulk_load_inventory_items_job_error,
                           bulk_load_inventory_items_job: bulk_load_inventory_items_jobs[0])
                }

                describe 'the response' do
                    it 'status equals 200 (OK)' do
                        get :index, params
                        expect(response.status).to be Rack::Utils.status_code(:ok)
                    end
                end

                describe 'the controller action' do
                    render_views

                    it 'assigns the retrieved bulk load jobs to the bulk_load_jobs instance variable' do
                        get :index, params
                        expect(assigns(:bulk_load_jobs).length).to eq 5
                    end

                    it 'renders the bulk_load_jobs instance variable as a JSON array' do
                        get :index, params
                        json = JSON.parse response.body
                        expect(json.length).to eq 5
                    end
                end
            end
        end

        describe 'GET #show' do
            context 'user is not signed in' do
                let(:current_user) { nil }
                let(:params) {
                    {
                        id: '78',
                        format: 'json'
                    }
                }

                describe 'the response' do
                    before :each do
                        get :index, params
                    end

                    it 'status equals 401 (Unauthorized)' do
                        expect(response.status).to be Rack::Utils.status_code(:unauthorized)
                    end
                end
            end

            context 'user is signed in' do
                render_views

                include_context 'a current user'

                let!(:bulk_load_inventory_items_job) { create :bulk_load_inventory_items_job, user: current_user }
                let(:pattern) {
                    {
                        id: bulk_load_inventory_items_job.id,
                        status: 'PENDING',
                        verify_only: false,
                        total_items_count: 0,
                        added_items_count: 0,
                        skipped_items_count: 0,
                        user: {
                            id: current_user.id,
                            email: current_user.email,
                            first_name: current_user.first_name,
                            last_name: current_user.last_name
                        },
                        bulk_load_inventory_items_job_errors: [],
                        job_started: nil,
                        job_finished: nil,
                        created_at: wildcard_matcher,
                        updated_at: wildcard_matcher,
                        has_errors: false
                    }
                }
                let(:params) {
                    {
                        id: bulk_load_inventory_items_job.id.to_s,
                        format: 'json'
                    }
                }

                before :each do
                    get :show, params
                end

                describe 'response' do
                    it 'status equals 200 (OK)' do
                        expect(response.status).to be Rack::Utils.status_code(:ok)
                    end

                    it 'assigns bulk_load_inventory_items_job instance variable' do
                        expect(assigns(:bulk_load_inventory_items_job)).not_to be_nil
                    end

                    it 'body matches pattern' do
                        expect(response.body).to match_json_expression(pattern)
                    end
                end
            end
        end

        describe 'POST #create' do
            include_context 'a current user'

            let(:excel_file) {
                Rack::Test::UploadedFile.new(
                    File.new("#{Rails.root}/spec/fixtures/files/test-bulk-load-inventory-items.xlsx"),
                    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
                )
            }

            let(:csv_file) {
                Rack::Test::UploadedFile.new(
                    File.new("#{Rails.root}/spec/fixtures/files/test-bulk-load-inventory-items.csv"),
                    'text/csv'
                )
            }

            let(:outcome) {UseCase::SuccessfulOutcome.new(true)}


            context 'PurchaseItem' do
                let(:params) {
                    {
                        file: upload_file,
                        verify_only: 'false',
                        format: 'html'
                    }
                }

                context 'successful outcome' do
                    context 'Excel file' do
                        let(:upload_file) { excel_file }

                        before :each do
                            expect_any_instance_of(UseCases::PurchaseItems::BulkLoadPurchaseItemsExcel).to receive(:execute).
                                and_return(outcome)
                            post :create, params
                        end

                        it 'the response should be 201 (Created)' do
                            expect(response.status).to eq Rack::Utils.status_code(:created)
                        end
                    end

                    context 'CSV file' do
                        let(:upload_file) { csv_file }

                        before :each do
                            expect_any_instance_of(UseCases::PurchaseItems::BulkLoadPurchaseItemsCsv).to receive(:execute).
                                and_return(outcome)
                            post :create, params
                        end

                        it 'the response should be 201 (Created)' do
                            expect(response.status).to eq Rack::Utils.status_code(:created)
                        end
                    end
                end
            end

            context 'HousemadeItem' do
                let(:params) {
                    {
                        file: upload_file,
                        verify_only: 'false',
                        housemade: 'true',
                        format: 'html'
                    }
                }

                context 'successful outcome' do
                    context 'Excel file' do
                        let(:upload_file) { excel_file }

                        before :each do
                            expect_any_instance_of(UseCases::HousemadeItems::BulkLoadHousemadeItemsExcel).to receive(:execute).
                                and_return(outcome)
                            post :create, params
                        end

                        it 'the response should be 201 (Created)' do
                            expect(response.status).to eq Rack::Utils.status_code(:created)
                        end
                    end

                    context 'CSV file' do
                        let(:upload_file) { csv_file }

                        before :each do
                            expect_any_instance_of(UseCases::HousemadeItems::BulkLoadHousemadeItemsCsv).to receive(:execute).
                                and_return(outcome)
                            post :create, params
                        end

                        it 'the response should be 201 (Created)' do
                            expect(response.status).to eq Rack::Utils.status_code(:created)
                        end
                    end
                end
            end

            context 'Beginning Costs' do
                let(:params) {
                    {
                        file: upload_file,
                        verify_only: 'false',
                        costs: 'true',
                        format: 'html'
                    }
                }

                context 'successful outcome' do
                    context 'Excel file' do
                        let(:upload_file) { excel_file }

                        before :each do
                            expect_any_instance_of(UseCases::PurchaseItems::BulkLoadBeginningCostsExcel).to receive(:execute).
                                and_return(outcome)
                            post :create, params
                        end

                        it 'the response should be 201 (Created)' do
                            expect(response.status).to eq Rack::Utils.status_code(:created)
                        end
                    end

                    context 'CSV file' do
                        let(:upload_file) { csv_file }

                        before :each do
                            expect_any_instance_of(UseCases::PurchaseItems::BulkLoadBeginningCostsCsv).to receive(:execute).
                                and_return(outcome)
                            post :create, params
                        end

                        it 'the response should be 201 (Created)' do
                            expect(response.status).to eq Rack::Utils.status_code(:created)
                        end
                    end
                end
            end
        end

    end
end
