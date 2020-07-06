class BulkLoadInventoryItemsJobsController < ApplicationController

    before_action :authenticate_user!

    # GET /api/bulk_load_inventory_items_jobs
    def index
        @bulk_load_jobs = BulkLoadInventoryItemsJob
            .where(user_id: current_user.id)
            .order(created_at: :desc)

        render template: 'bulk_load_inventory_items_jobs/index'
    end

    # GET /api/bulk_load_inventory_items_jobs/:id
    def show
        @bulk_load_inventory_items_job = BulkLoadInventoryItemsJob.find params[:id]
    end

    # POST /api/bulk_load_inventory_items_jobs
    def create
        verify_only = false
        if params[:verify_only]
            if params[:verify_only].downcase == 'true'
                verify_only = true
            end
        end

        housemade_job = params[:housemade]
        costs_job = params[:costs]

        file = params[:file]
        if file
            file_contents = file.read {|io| io.data}

            @bulk_load_inventory_items_job = BulkLoadInventoryItemsJob.new file_contents: file_contents,
                                                                           content_type: file.content_type
            @bulk_load_inventory_items_job.verify_only = verify_only
            @bulk_load_inventory_items_job.user = current_user
            @bulk_load_inventory_items_job.save!

            if costs_job
                if @bulk_load_inventory_items_job.is_excel_file?
                    use_case = UseCases::PurchaseItems::BulkLoadBeginningCostsExcel.new
                else
                    use_case = UseCases::PurchaseItems::BulkLoadBeginningCostsCsv.new
                end
            elsif housemade_job
                if @bulk_load_inventory_items_job.is_excel_file?
                    use_case = UseCases::HousemadeItems::BulkLoadHousemadeItemsExcel.new
                else
                    use_case = UseCases::HousemadeItems::BulkLoadHousemadeItemsCsv.new
                end
            else
                if @bulk_load_inventory_items_job.is_excel_file?
                    use_case = UseCases::PurchaseItems::BulkLoadPurchaseItemsExcel.new
                else
                    use_case = UseCases::PurchaseItems::BulkLoadPurchaseItemsCsv.new
                end
            end

            outcome = nil
            begin
                outcome = use_case.execute user_id: current_user.id,
                                           service_provider_id: current_user.organization.id,
                                           bulk_load_inventory_items_job_id: @bulk_load_inventory_items_job.id,
                                           verify_spreadsheet_only: verify_only
            rescue => e
                logger.error e.message
                logger.error e.backtrace.join("\n")
            end

            status = nil
            if verify_only
                status = :ok
            elsif outcome && outcome.success
                status = :created
            else
                status = :unprocessable_entity
            end

            @bulk_load_inventory_items_job.reload

            respond_to do |format|
                format.html {
                    render template: 'bulk_load_inventory_items_jobs/show',
                           status: status
                }
            end

        else
            respond_to do |format|
                format.html {
                    render text: 'No file was uploaded to the server.',
                           status: :unprocessable_entity
                }
            end
        end
    end
end
