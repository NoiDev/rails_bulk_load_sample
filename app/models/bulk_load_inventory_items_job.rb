# == Schema Information
#
# Table name: bulk_load_inventory_items_jobs
#
# *added_items_count*::   <tt>integer, default(0), not null</tt>
# *content_type*::        <tt>string(255), default("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"), not null</tt>
# *created_at*::          <tt>datetime, not null</tt>
# *file_contents*::       <tt>binary, not null</tt>
# *id*::                  <tt>integer, not null, primary key</tt>
# *job_finished*::        <tt>datetime</tt>
# *job_started*::         <tt>datetime</tt>
# *skipped_items_count*:: <tt>integer, default(0), not null</tt>
# *status*::              <tt>string(255), default("PENDING"), not null</tt>
# *total_items_count*::   <tt>integer, default(0), not null</tt>
# *updated_at*::          <tt>datetime, not null</tt>
# *user_id*::             <tt>integer, not null</tt>
# *verify_only*::         <tt>boolean, default(FALSE), not null</tt>
#
# Foreign Keys
#
#  bulk_load_inventory_items_jobs_users_fk  (user_id => users.id)
#--
# == Schema Information End
#++

class BulkLoadInventoryItemsJob < ActiveRecord::Base

    attr_accessible :file_contents,
                    :status,
                    :job_started,
                    :job_finished,
                    :verify_only,
                    :total_items_count,
                    :added_items_count,
                    :skipped_items_count,
                    :content_type

    belongs_to :user

    has_many :bulk_load_inventory_items_job_errors

    CONTENT_TYPE_EXCEL = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
    CONTENT_TYPE_CSV = 'text/csv'

    def has_errors?
        bulk_load_inventory_items_job_errors.length > 0
    end

    def is_excel_file?
        content_type == CONTENT_TYPE_EXCEL
    end

    def is_csv_file?
        content_type == CONTENT_TYPE_CSV
    end
end
