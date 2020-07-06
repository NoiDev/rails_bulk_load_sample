require 'use_cases/bulk_load/bulk_load_job'

module UseCases
    module BulkLoad
        class ExcelInput < BaseInput
            def spreadsheet_workbook
                @spreadsheet_workbook ||= load_spreadsheet
            end

            protected

            def load_spreadsheet
                tmp_dir = Rails.root.join('tmp')
                unless Dir.exists?(tmp_dir)
                    Dir.mkdir(tmp_dir, 0755)
                end
                spreadsheets_dir = tmp_dir.join('bulk_load_inventory_items')
                unless Dir.exists?(spreadsheets_dir)
                    Dir.mkdir(spreadsheets_dir, 0755)
                end
                spreadsheet_path = spreadsheets_dir.join("spreadsheet-#{@bulk_load_inventory_items_job.id}.xlsx")
                File.open(spreadsheet_path, 'wb') { |file| file.write(@bulk_load_inventory_items_job.file_contents) }

                workbook = SimpleSpreadsheet::Workbook.read(spreadsheet_path.to_s)
                workbook.selected_sheet = workbook.sheets.first

                workbook
            end
        end

        module ExcelDataAccessHelpers
            def get_first_row_index(context)
                context.spreadsheet_workbook.first_row
            end

            def get_last_row_index(context)
                context.spreadsheet_workbook.last_row
            end

            def get_value_for_cell(row_index, column_index, context)
                # Note: The spreadsheet library starts column indexes at 1.
                context.spreadsheet_workbook.cell(row_index,
                                                  column_index)
            end
        end

        class VerifyExcelDataCommand < VerifyDataCommand
            include ExcelDataAccessHelpers
        end

        class LoadExcelDataCommand < LoadDataCommand
            include ExcelDataAccessHelpers
        end

        class ExcelLoadProcess < LoadProcess
            def get_input_class
                UseCases::BulkLoad::ExcelInput
            end

            def verify_data_step
                UseCases::BulkLoad::VerifyExcelDataCommand.new
            end

            def load_data_step
                UseCases::BulkLoad::LoadExcelDataCommand.new
            end
        end
    end
end
