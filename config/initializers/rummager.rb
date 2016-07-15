require 'gds_api/rummager'
require 'search_api'
rummager_host = ENV["RUMMAGER_HOST"] || Plek.current.find('search')

Frontend.rummager_adapter = GdsApi::Rummager.new(rummager_host)
Frontend.search_client = SearchAPI.new(Frontend.rummager_adapter)
