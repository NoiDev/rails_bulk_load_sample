SampleApp::Application.routes.draw do

    # REST web services
    scope '/api/' do

        # Bulk Load Inventory Items Jobs
        resources :bulk_load_inventory_items_jobs, only: [:index, :show, :create]

        # Note: Other routes REDACTED

    end
end
