require 'rails_helper'

describe 'UseCase: BulkLoadPurchaseItemsCsv' do
    include_context 'a bulk load scenario'

    let(:use_case) { UseCases::PurchaseItems::BulkLoadPurchaseItemsCsv.new }

    context 'verify spreadsheet only' do
        context 'successful outcome' do
            let(:spreadsheet_file) { File.new('spec/use_cases/purchase_items/spreadsheets/bulk-load-inventory-items-no-errors.csv') }
            let(:bulk_load_inventory_items_job) {
                job = create_bulk_load_inventory_items_job(spreadsheet_file.read { |io| io.data }, true)
                job.user = current_user
                job.save!
                job
            }

            let!(:use_case_execution_parameters) {
                {
                    user_id: current_user.id,
                    service_provider_id: restaurant.id,
                    bulk_load_inventory_items_job_id: bulk_load_inventory_items_job.id,
                    verify_spreadsheet_only: bulk_load_inventory_items_job.verify_only?
                }
            }
            let!(:outcome) { use_case.execute use_case_execution_parameters }

            it 'outcome will be successful' do
                expect(outcome.success?).to be true
            end

            it 'will not create any new inventory items' do
                expect(InventoryItem.where(service_provider_id: restaurant.id).count).to eq 0
            end

            it 'will not create any new vendor inventory items' do
                expect(VendorInventoryItem.
                    joins(:inventory_item).
                    where('inventory_items.service_provider_id = ?', restaurant.id).count).to eq 0
            end

            it 'will not create any new service provider expense categories' do
                expect(AccountingCategory.where(service_provider_id: restaurant.id).count).to eq 2
            end
        end

        context 'failure outcome' do
            let(:spreadsheet_file) { File.new('spec/use_cases/purchase_items/spreadsheets/bulk-load-inventory-items-has-errors.csv') }
            let(:bulk_load_inventory_items_job) {
                job = create_bulk_load_inventory_items_job(spreadsheet_file.read { |io| io.data }, true)
                job.user = current_user
                job.save!
                job
            }
            let!(:use_case_execution_parameters) {
                {
                    user_id: current_user.id,
                    service_provider_id: restaurant.id,
                    bulk_load_inventory_items_job_id: bulk_load_inventory_items_job.id,
                    verify_spreadsheet_only: bulk_load_inventory_items_job.verify_only?
                }
            }

            it 'will create job error objects' do
                begin
                    use_case.execute use_case_execution_parameters
                rescue RuntimeError
                    expect(BulkLoadInventoryItemsJobError.
                        where(bulk_load_inventory_items_job_id: bulk_load_inventory_items_job.id).count).to eq 11
                end
            end
        end
    end

    context 'verify and load spreadsheet contents' do
        let(:spreadsheet_file) { File.new('spec/use_cases/purchase_items/spreadsheets/bulk-load-inventory-items-no-errors.csv') }
        let(:bulk_load_inventory_items_job) {
            job = create_bulk_load_inventory_items_job(spreadsheet_file.read { |io| io.data })
            job.user = current_user
            job.save!
            job
        }

        context 'successful outcome' do
            let!(:use_case_execution_parameters) {
                {
                    user_id: current_user.id,
                    service_provider_id: restaurant.id,
                    bulk_load_inventory_items_job_id: bulk_load_inventory_items_job.id,
                    verify_spreadsheet_only: bulk_load_inventory_items_job.verify_only?
                }
            }
            let!(:outcome) { use_case.execute use_case_execution_parameters }
            let(:olives_inventory_item) { InventoryItem.where(name: 'Olives, bleu cheese stuffed').first }
            let(:cloth_napkins) { 'Cloth napkins' }
            let(:cloth_napkins_inventory_item) { InventoryItem.where(name: cloth_napkins).first }

            it 'outcome will be successful' do
                expect(outcome.success?).to be true
            end

            context 'inventory items' do
                context 'olives, bleu cheese stuffed' do
                    let(:vendor_inventory_item) {
                        olives_inventory_item.vendor_inventory_items.find { |vii| vii.primary_vendor == true }
                    }

                    it 'is created' do
                        expect(InventoryItem.where(name: 'Olives, bleu cheese stuffed').count).to eq 1
                    end

                    it 'has the expense category set' do
                        expect(olives_inventory_item.accounting_category).not_to be_nil
                    end

                    it 'has the restaurant identifier set' do
                        expect(olives_inventory_item.restaurant_identifier).to eq '007989897'
                    end

                    it 'is created' do
                        expect(olives_inventory_item.vendor_inventory_items.length).to eq 1
                    end

                    it 'the item unit is set appropriately' do
                        expect(olives_inventory_item.item_unit.unit.name).to eq 'Package'
                    end

                    it 'the taxable property is set appropriately' do
                        expect(olives_inventory_item.taxable).to be_falsey
                    end

                    it 'has the vendor specific identifier set on the vendor inventory item model' do
                        expect(vendor_inventory_item.vendor_specific_identifier).to eq '7432'
                    end

                    it 'the primary vendor is set appropriately' do
                        expect(vendor_inventory_item.vendor.key).to eq 'ciao_bella_united_foods'
                    end

                    it 'the order unit property is set appropriately' do
                        expect(vendor_inventory_item.order_unit.unit.name).to eq 'Case'
                    end

                    it 'the pack value is set appropriately' do
                        expect(vendor_inventory_item.pack_value).to eq 12
                    end
                end

                context 'cloth napkins' do
                    let(:vendor_inventory_item) {
                        cloth_napkins_inventory_item.vendor_inventory_items.find { |vii| vii.primary_vendor == true }
                    }

                    it 'is created' do
                        expect(InventoryItem.where(name: cloth_napkins).count).to eq 1
                    end

                    it 'has the expense category set' do
                        expect(cloth_napkins_inventory_item.accounting_category).not_to be_nil
                    end

                    it 'has the restaurant identifier set' do
                        expect(cloth_napkins_inventory_item.restaurant_identifier).to eq '007848867'
                    end

                    it 'is created' do
                        expect(cloth_napkins_inventory_item.vendor_inventory_items.length).to eq 1
                    end


                    it 'the item unit is set appropriately' do
                        expect(cloth_napkins_inventory_item.item_unit.unit.name).to eq 'Box'
                    end

                    it 'the taxable property is set appropriately' do
                        expect(cloth_napkins_inventory_item.taxable).to be_truthy
                    end

                    it 'the vendor specific identifier is blank (it was not specified in bulk load file)' do
                        expect(vendor_inventory_item.vendor_specific_identifier).to eq ''
                    end

                    it 'the primary vendor is set appropriately' do
                        expect(vendor_inventory_item.vendor.key).to eq 'ciao_bella_united_foods'
                    end

                    it 'the order unit property is set appropriately' do
                        expect(vendor_inventory_item.order_unit.unit.name).to eq 'Case'
                    end

                    it 'the pack value is set appropriately' do
                        expect(vendor_inventory_item.pack_value).to eq 24
                    end
                end
            end

            it 'creates a new expense category' do
                matching_expense_categories = AccountingCategory.where(expense_name: 'Food').load
                expect(matching_expense_categories.length).to eq 1
            end

            it 'reuses existing expense category' do
                new_inventory_item = InventoryItem.where(name: cloth_napkins).first
                expect(new_inventory_item.accounting_category).to eq supplies_accounting_category
            end
        end

        context 'failure outcome' do
            context 'missing user_id' do
                let!(:outcome) { use_case.execute({bulk_load_inventory_items_job_id: bulk_load_inventory_items_job.id}) }

                it 'outcome will not be successful' do
                    expect(outcome.success?).to be false
                end
            end

            context 'missing bulk_load_inventory_items_job_id' do
                let!(:outcome) { use_case.execute({user_id: current_user.id}) }

                it 'outcome will not be successful' do
                    expect(outcome.success?).to be false
                end
            end
        end
    end

    context 'multiple vendor/inventory item associations' do
        include_context 'a current user'

        let!(:vendor2) {
            create :vendor,
                   name: 'Sysco Minnesota',
                   vendor_identifier: 'sysco',
                   service_provider: restaurant
        }
        let!(:spreadsheet_file) { File.new('spec/use_cases/purchase_items/spreadsheets/bulk-load-inventory-items-multiple-vendors.csv') }
        let(:bulk_load_inventory_items_job) {
            job = create_bulk_load_inventory_items_job(spreadsheet_file.read { |io| io.data })
            job.user = current_user
            job.save!
            job
        }
        let!(:use_case_execution_parameters) {
            {
                user_id: current_user.id,
                service_provider_id: restaurant.id,
                bulk_load_inventory_items_job_id: bulk_load_inventory_items_job.id,
                verify_spreadsheet_only: bulk_load_inventory_items_job.verify_only?
            }
        }
        let(:inventory_item_name) {'Olives, bleu cheese stuffed'} # Note: Must match spreadsheet

        before :each do
            @outcome=use_case.execute use_case_execution_parameters
        end

        it 'outcome will be successful' do
            expect(@outcome.success?).to be true
        end

        it 'creates no errors' do
            bulk_load_inventory_items_job.reload
            expect(bulk_load_inventory_items_job.bulk_load_inventory_items_job_errors).to eq []
        end

        context 'inventory item' do
            it 'is created only once' do
                count = InventoryItem
                    .where(name: inventory_item_name)
                    .count
                expect(count).to eq 1
            end
        end

        context 'vendor inventory items' do
            inventory_item = nil

            before :each do
                inventory_item = InventoryItem
                    .where(name: inventory_item_name)
                    .first
            end

            it 'is created twice' do
                expect(inventory_item.vendor_inventory_items.length).to eq 2
            end

            it 'only one vendor_inventory_item is set as :primary_vendor' do
                primary_vendor_inventory_items = VendorInventoryItem
                    .by_inventory_item(inventory_item)
                    .primary_vendor
                expect(primary_vendor_inventory_items.count).to eq 1
            end

            it 'sets the correct vendor as :primary_vendor' do
                expect(inventory_item.primary_vendor).to eq vendor
            end
        end
    end

    context 'duplicate vendor/inventory item associations' do
        include_context 'a current user'

        let!(:spreadsheet_file) { File.new('spec/use_cases/purchase_items/spreadsheets/bulk-load-inventory-items-duplicate-items.csv') }
        let(:bulk_load_inventory_items_job) {
            job = create_bulk_load_inventory_items_job(spreadsheet_file.read { |io| io.data })
            job.user = current_user
            job.save!
            job
        }
        let!(:use_case_execution_parameters) {
            {
                user_id: current_user.id,
                service_provider_id: restaurant.id,
                bulk_load_inventory_items_job_id: bulk_load_inventory_items_job.id,
                verify_spreadsheet_only: bulk_load_inventory_items_job.verify_only?
            }
        }
        let(:inventory_item_name) {'Olives, bleu cheese stuffed'} # Note: Must match spreadsheet


        before :each do
            @outcome=use_case.execute use_case_execution_parameters
        end

        it 'outcome will be successful' do
            expect(@outcome.success?).to be true
        end

        it 'creates no errors' do
            bulk_load_inventory_items_job.reload
            expect(bulk_load_inventory_items_job.bulk_load_inventory_items_job_errors).to eq []
        end

        context 'inventory item' do
            it 'is created only once' do
                count = InventoryItem
                    .where(name: inventory_item_name)
                    .count
                expect(count).to eq 1
            end
        end

        context 'vendor inventory items' do
            inventory_item = nil

            before :each do
                inventory_item = InventoryItem
                    .where(name: inventory_item_name)
                    .first
            end

            it 'creates only one unique association' do
                expect(inventory_item.vendor_inventory_items.length).to eq 1
            end

            it 'is primary vendor' do
                primary_vendor_inventory_items = VendorInventoryItem
                    .by_inventory_item(inventory_item)
                    .primary_vendor
                expect(primary_vendor_inventory_items.count).to eq 1
            end
        end
    end

    context 'duplicate item codes for vendor/inventory item associations' do
        include_context 'a current user'

        let!(:spreadsheet_file) { File.new('spec/use_cases/purchase_items/spreadsheets/bulk-load-inventory-items-duplicate-item-codes.csv') }
        let(:bulk_load_inventory_items_job) {
            job = create_bulk_load_inventory_items_job(spreadsheet_file.read { |io| io.data })
            job.user = current_user
            job.save!
            job
        }
        let!(:use_case_execution_parameters) {
            {
                user_id: current_user.id,
                service_provider_id: restaurant.id,
                bulk_load_inventory_items_job_id: bulk_load_inventory_items_job.id,
                verify_spreadsheet_only: bulk_load_inventory_items_job.verify_only?
            }
        }
        let(:inventory_item_name) {'Olives, bleu cheese stuffed'} # Note: Must match spreadsheet


        before :each do
            @outcome=use_case.execute use_case_execution_parameters
        end

        it 'outcome will be successful' do
            expect(@outcome.success?).to be true
        end

        it 'creates no errors' do
            bulk_load_inventory_items_job.reload
            expect(bulk_load_inventory_items_job.bulk_load_inventory_items_job_errors).to eq []
        end

        context 'inventory item' do
            it 'is created only once' do
                count = InventoryItem
                    .where(name: inventory_item_name)
                    .count
                expect(count).to eq 1
            end
        end

        context 'vendor inventory items' do
            inventory_item = nil

            before :each do
                inventory_item = InventoryItem
                    .where(name: inventory_item_name)
                    .first
            end

            it 'creates an association for each unique identifier-unit pair' do
                expect(inventory_item.vendor_inventory_items.length).to eq 4
            end
        end
    end

    private

    def create_bulk_load_inventory_items_job(contents, verify_only=false)
        BulkLoadInventoryItemsJob.new(file_contents: contents,
                                      content_type: BulkLoadInventoryItemsJob::CONTENT_TYPE_CSV,
                                      verify_only: verify_only)
    end
end
