require 'use_cases/bulk_load/bulk_load_excel_job'
require 'use_cases/purchase_items/bulk_load_beginning_costs'

module UseCases
    module PurchaseItems

        class VerifyBeginningCostsExcelDataCommand < BulkLoad::VerifyExcelDataCommand
            include VerifyBeginningCostsDataHelper
        end

        class LoadBeginningCostsExcelDataCommand < BulkLoad::LoadExcelDataCommand
            include LoadBeginningCostsDataHelper
        end

        class BulkLoadBeginningCostsExcel < BulkLoad::ExcelLoadProcess
            def verify_data_step
                UseCases::PurchaseItems::VerifyBeginningCostsExcelDataCommand.new
            end

            def load_data_step
                UseCases::PurchaseItems::LoadBeginningCostsExcelDataCommand.new
            end
        end
    end
end
