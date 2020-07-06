require 'use_cases/bulk_load/bulk_load_excel_job'
require 'use_cases/housemade_items/bulk_load_housemade_items'

module UseCases
    module HousemadeItems

        class VerifyHousemadeItemsExcelDataCommand < BulkLoad::VerifyExcelDataCommand
            include VerifyHousemadeItemsDataHelper
        end

        class LoadHousemadeItemsExcelDataCommand < BulkLoad::LoadExcelDataCommand
            include LoadHousemadeItemsDataHelper
        end

        class BulkLoadHousemadeItemsExcel < BulkLoad::ExcelLoadProcess
            def verify_data_step
                UseCases::HousemadeItems::VerifyHousemadeItemsExcelDataCommand.new
            end

            def load_data_step
                UseCases::HousemadeItems::LoadHousemadeItemsExcelDataCommand.new
            end
        end
    end
end

