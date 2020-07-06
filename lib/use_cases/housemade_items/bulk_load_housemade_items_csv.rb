require 'use_cases/bulk_load/bulk_load_csv_job'
require 'use_cases/housemade_items/bulk_load_housemade_items'

module UseCases
    module HousemadeItems

        class VerifyHousemadeItemsCsvDataCommand < BulkLoad::VerifyCsvDataCommand
            include VerifyHousemadeItemsDataHelper
        end

        class LoadHousemadeItemsCsvDataCommand < BulkLoad::LoadCsvDataCommand
            include LoadHousemadeItemsDataHelper
        end

        class BulkLoadHousemadeItemsCsv < BulkLoad::CsvLoadProcess
            def verify_data_step
                UseCases::HousemadeItems::VerifyHousemadeItemsCsvDataCommand.new
            end

            def load_data_step
                UseCases::HousemadeItems::LoadHousemadeItemsCsvDataCommand.new
            end
        end
    end
end
