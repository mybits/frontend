require "slimmer/headers"

class SearchController < ApplicationController

  before_filter :setup_slimmer_artefact, only: :index
  before_filter :set_expiry
  before_filter :remove_search_box

  rescue_from GdsApi::BaseError, with: :error_503

  def index
    search_params = SearchParameters.new(params)

    if search_params.no_search? && params[:format] != "json"
      render action: 'no_search_term' and return
    end
    search_response = search_client.search(search_params)

    @search_term = search_params.search_term

    if (search_response["scope"].present?)
      @results = ScopedSearchResultsPresenter.new(search_response, search_params)
    else
      if @search_term.downcase == 'education'
        popular_results_response = rummager_adapter.unified_search(filter_taxons: ['9224b0fb-0701-4fb3-a563-1fb744e60359'], count: 6)
      end

      @results = SearchResultsPresenter.new(search_response, search_params, popular_results_response: popular_results_response)
    end

    @facets = search_response["facets"]
    @spelling_suggestion = @results.spelling_suggestion

    fill_in_slimmer_headers(@results.result_count)

    respond_to do |format|
      format.html { render locals: { full_width: true } }
      format.json do
        render json: @results
      end
    end
  end

protected

  def search_client
    Frontend.search_client
  end

  def rummager_adapter
    Frontend.rummager_adapter
  end

  def remove_search_box
    set_slimmer_headers(remove_search: true)
  end

  def fill_in_slimmer_headers(result_count)
    set_slimmer_headers(
      result_count: result_count,
      format:       "search",
      section:      "search",
    )
  end

  def setup_slimmer_artefact
    set_slimmer_dummy_artefact(:section_name => "Search", :section_link => "/search")
  end
end
