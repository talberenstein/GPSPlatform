Rails.application.routes.draw do
  resources :command_requests
  get 'webservice/index'


		resources :drivers, only: [:index, :create, :update, :destroy]
		resources :companies, only: [:index, :create, :update, :destroy] do
			resources :groups, only: [:index, :create, :update, :destroy]
    end
		resources :groups, only: [:index, :create, :update, :destroy]
		resources :geo_zones, only: [:index, :create, :update, :destroy]
		resources :devices, only: [:create, :update, :destroy]
		resources :events, only: [:create, :update, :destroy]
		resources :device_events, only: [:create, :update, :destroy]

		resources :owners, only: [:index, :create, :update, :destroy]
		resources :couples_types, only: [:index, :create, :update, :destroy]
		resources :travel_sheets, only: [:index, :create, :update, :destroy]
		resources :locations, only: [:index, :create, :update, :destroy]
		resources :informations, only: [:index, :create, :update, :destroy]

		resources :waze, defaults: {format: 'json'}, only: [:index]

		resources :alerts, only: [] do
				put 'seen', on: :member
		end
		devise_for :users
		resources :users, only: [:create, :update, :destroy]


		resources :travel_sheets do
				collection do
						get :search
						get :details
						get :edit
						get :get_state
						get :set_state
				end
		end

		get 'travel_sheets/details'

		resources :informations do
				collection do
						get :info

				end
		end
		get 'informations/info'

		get 'information/report_speeds'
    get 'information/report_stops'
    get 'information/report_geozones'
    get 'information/report_dialyActivities'
		get 'information/report_activities'
    get 'information/report_alerts'
		get 'information/report_playback'

  	get 'command_requests/new'


		get 'pages/index'
		get 'reports/speeds'
    get 'reports/stops'
		get 'reports/stops'
		get 'reports/path'
		#get 'reports/dialyActivities'
		get 'reports/geo_zones_histories'
		get 'reports/speeds_graph'
		get 'reports/stops_graph'

		get 'waze/index'
  	get 'webservice/index'

		get 'groups/update_groups', :as => 'update_groups'


		root 'pages#index'
end
