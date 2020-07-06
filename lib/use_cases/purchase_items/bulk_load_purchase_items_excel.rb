require 'use_cases/bulk_load/bulk_load_excel_job'
require 'use_cases/purchase_items/bulk_load_purchase_items'

module UseCases
    module PurchaseItems

        class VerifyPurchaseItemsExcelDataCommand < BulkLoad::VerifyExcelDataCommand
            include VerifyPurchaseItemsDataHelper
        end

        class LoadPurchaseItemsExcelDataCommand < BulkLoad::LoadExcelDataCommand
            include LoadPurchaseItemsDataHelper
        end

        class BulkLoadPurchaseItemsExcel < BulkLoad::ExcelLoadProcess
            def verify_data_step
                UseCases::PurchaseItems::VerifyPurchaseItemsExcelDataCommand.new
            end

            def load_data_step
                UseCases::PurchaseItems::LoadPurchaseItemsExcelDataCommand.new
            end
        end
    end
end
