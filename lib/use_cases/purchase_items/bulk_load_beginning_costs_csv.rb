require 'use_cases/bulk_load/bulk_load_csv_job'
require 'use_cases/purchase_items/bulk_load_beginning_costs'

module UseCases
    module PurchaseItems

        class VerifyBeginningCostsCsvDataCommand < BulkLoad::VerifyCsvDataCommand
            include VerifyBeginningCostsDataHelper
        end

        class LoadBeginningCostsCsvDataCommand < BulkLoad::LoadCsvDataCommand
            include LoadBeginningCostsDataHelper
        end

        class BulkLoadBeginningCostsCsv < BulkLoad::CsvLoadProcess
            def verify_data_step
                UseCases::PurchaseItems::VerifyBeginningCostsCsvDataCommand.new
            end

            def load_data_step
                UseCases::PurchaseItems::LoadBeginningCostsCsvDataCommand.new
            end
        end
    end
end
