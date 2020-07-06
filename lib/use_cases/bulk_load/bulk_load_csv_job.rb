require 'use_cases/bulk_load/bulk_load_job'

module UseCases
    module BulkLoad
        class CsvInput < BaseInput
            def csv_data_array
                @csv_data_array ||= CSV.new(bulk_load_inventory_items_job.file_contents).to_a
            end
        end

        module CsvDataAccessHelpers
            # Note: Use values 1..[length] for row_index to match output for Excel files.

            def get_first_row_index(context)
                1
            end

            def get_last_row_index(context)
                context.csv_data_array.length
            end

            def get_value_for_cell(row_index, column_index, context)
                # Note: The CSV library starts row indexes at 0.
                # Note: The CSV library starts column indexes at 0.
                row = context.csv_data_array[row_index - 1]
                row[column_index-1]
            end
        end

        class VerifyCsvDataCommand < VerifyDataCommand
            include CsvDataAccessHelpers
        end

        class LoadCsvDataCommand < LoadDataCommand
            include CsvDataAccessHelpers
        end

        class CsvLoadProcess < LoadProcess
            def get_input_class
                UseCases::BulkLoad::CsvInput
            end

            def verify_data_step
                UseCases::BulkLoad::VerifyCsvDataCommand.new
            end

            def load_data_step
                UseCases::BulkLoad::LoadCsvDataCommand.new
            end
        end
    end
end
