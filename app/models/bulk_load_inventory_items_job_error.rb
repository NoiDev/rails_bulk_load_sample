# == Schema Information
#
# Table name: bulk_load_inventory_items_job_errors
#
# *bulk_load_inventory_items_job_id*:: <tt>integer, not null</tt>
# *created_at*::                       <tt>datetime, not null</tt>
# *description*::                      <tt>string(1024), default("ERROR"), not null</tt>
# *id*::                               <tt>integer, not null, primary key</tt>
# *spreadsheet_column*::               <tt>integer, not null</tt>
# *spreadsheet_row*::                  <tt>integer, not null</tt>
# *updated_at*::                       <tt>datetime, not null</tt>
#
# Foreign Keys
#
#  bulk_load_inventory_items_jobs_fk  (bulk_load_inventory_items_job_id => bulk_load_inventory_items_jobs.id)
#--
# == Schema Information End
#++

class BulkLoadInventoryItemsJobError < ActiveRecord::Base

    attr_accessible :spreadsheet_row,
                    :spreadsheet_column,
                    :description

    belongs_to :bulk_load_inventory_items_job
end
