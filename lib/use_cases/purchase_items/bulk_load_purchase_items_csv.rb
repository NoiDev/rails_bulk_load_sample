require 'use_cases/bulk_load/bulk_load_csv_job'
require 'use_cases/purchase_items/bulk_load_purchase_items'

module UseCases
    module PurchaseItems

        class VerifyPurchaseItemsCsvDataCommand < BulkLoad::VerifyCsvDataCommand
            include VerifyPurchaseItemsDataHelper
        end

        class LoadPurchaseItemsCsvDataCommand < BulkLoad::LoadCsvDataCommand
            include LoadPurchaseItemsDataHelper
        end

        class BulkLoadPurchaseItemsCsv < BulkLoad::CsvLoadProcess
            def verify_data_step
                UseCases::PurchaseItems::VerifyPurchaseItemsCsvDataCommand.new
            end

            def load_data_step
                UseCases::PurchaseItems::LoadPurchaseItemsCsvDataCommand.new
            end
        end
    end
end
