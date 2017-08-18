class NetappClusterVif < NetappApiServer

  def initialize(host, init_user, init_pass)
    super
    unless is_cluster?
      raise IncorrectApiTypeError.new("#{host} appears not to be a cluster VIF and cannot be initialized")
    end
  end

  def aggregates(force_refresh=false)
    if !@_aggregates || force_refresh
      @_aggregates = []
      api_response = invoke_api_or_fail 'aggr-get-iter'
      next_tag = api_response.child_get_string 'next-tag'
      aggregate_list_element = api_response.child_get 'attributes-list'
      @_aggregates.concat get_aggregates_from_aggr_attributes_array_element aggregate_list_element
      while next_tag && (loop_iter ||= 0) < API_LOOP_LIMIT
         api_response = invoke_api_or_fail 'aggr-get-iter', 'tag', next_tag
         next_tag = api_response.child_get_string 'next-tag'
         aggregate_list_element = api_response.get_child 'attributes-list'
         @_aggregates.concat get_aggregates_from_aggr_attributes_array_element aggregate_list_element
         loop_iter += 1
      end
    end
    @_aggregates
  end

  private
  def get_aggregates_from_aggr_attributes_array_element(aggregate_list_element)
    return [] unless aggregate_list_element
    aggregate_list_element.children_get.map do |aggr_attributes_element|
      Aggregate.create_from_aggr_attributes_element aggr_attributes_element
    end
  end

end
