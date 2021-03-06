module ParamParser
  include GeneralUtils

  # Processes parameters for search query generation             
  def process_params
    processed_params = Hash.new
    model_to_search = @models
    
    # Search all fields
    if @params[:q]
      processed_params = search_all_fields(:q)
      
    # Search allfields on specific index
    elsif params_include?("all_sindex_")
      # Set processed params
      processed_params = search_all_fields(get_param_includes("all_sindex_").to_sym)
      
      # Get dataspec and model for index
      _, dataspec_to_search = get_search_param(@params)
      model_to_search = [get_model(dataspec_to_search.index_name)]

    # Search date params
    elsif params_include?("startrange_") || params_include?("endrange_") 
      dataspec_to_search, processed_params = process_date_params
      model_to_search = [get_model(dataspec_to_search.index_name)]
      
      
    # Search individual fields
    else
      begin
        # Get correct dataspec and item
        param_item, dataspec_to_search = get_search_param(@params)
      
        # Get params and model to search
        processed_params, model_to_search = find_field_param_match(param_item, dataspec_to_search)
      rescue
        # If it fails, it's probably because there's a facet
      end
    end
    
    processed_params == {} if processed_params.empty?
    return processed_params, model_to_search, dataspec_to_search
  end

  # Checks if any params include a particular phrase
  def params_include?(phrase)
    @params.each do |param|
      return true if param[0].include?(phrase)
    end

    return false
  end

  # Gets the first param that includes the phrase
  def get_param_includes(phrase)
    @params.each do |param|
      return param[0] if param[0].include?(phrase)
    end
  end

  # Sets field and searchterm for searching all fields, all indexes
  def search_all_fields(field)
    return {field: "_all", searchterm: @params[field]}
  end
  
  # Finds params that match for a given dataspec
  def find_field_param_match(param_item, dataspec)
    dataspec.searchable_fields.each do |field|
      # Find field that matches in dataspec and process
      if paramMatch?(getFieldDetails(field, dataspec.field_info), param_item)
        return process_param_by_type(field, dataspec)
      end
    end
  end

  # Gets name that would show up in params
  def unprocess_item_name(search_item, dataspec)
    return (search_item.to_s+"_sindex_"+dataspec.index_name).to_sym
  end


  # Split each field into field name and search terms for query processing        
  def process_param_by_type(search_item, dataspec)
    # Get field details and name to search
    item_info = getFieldDetails(search_item, dataspec.field_info)
    fieldname = search_item.to_sym

    # Check if it is a date and handle input differently if so      
    if item_info["Type"] == "Date"
      processed_params = process_date_params(fieldname, item_info, @params)

    # If not a date                                                              
    else
      processed_params = {
        field: fieldname,
        searchterm: @params[unprocess_item_name(search_item, dataspec)]
      }
    end
    
    # Return params and model to search
    return processed_params, [get_model(dataspec.index_name)]
  end
end
