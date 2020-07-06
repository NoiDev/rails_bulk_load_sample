collection @bulk_load_jobs, :object_root => false

    attributes :id,
               :status,
               :verify_only,
               :total_items_count,
               :added_items_count,
               :skipped_items_count

    node :job_started do |bulk_load_inventory_items_job|
        bulk_load_inventory_items_job.job_started.nil? ? nil : bulk_load_inventory_items_job.job_started.utc.iso8601
    end

    node :job_finished do |bulk_load_inventory_items_job|
        bulk_load_inventory_items_job.job_finished.nil? ? nil : bulk_load_inventory_items_job.job_finished.utc.iso8601
    end

    node :created_at do |bulk_load_inventory_items_job|
        bulk_load_inventory_items_job.created_at.utc.iso8601
    end

    node :updated_at do |bulk_load_inventory_items_job|
        bulk_load_inventory_items_job.updated_at.utc.iso8601
    end

    node(:has_errors) do |bulk_load_inventory_items_job|
        bulk_load_inventory_items_job.has_errors?
    end

    child(:user) {
        attributes :id,
                   :email,
                   :first_name,
                   :last_name
    }

    child(:bulk_load_inventory_items_job_errors) {
        attributes :id,
                   :spreadsheet_row,
                   :spreadsheet_column,
                   :description

        node :created_at do |bulk_load_inventory_items_job_error|
            bulk_load_inventory_items_job_error.created_at.utc.iso8601
        end

        node :updated_at do |bulk_load_inventory_items_job_error|
            bulk_load_inventory_items_job_error.updated_at.utc.iso8601
        end
    }
