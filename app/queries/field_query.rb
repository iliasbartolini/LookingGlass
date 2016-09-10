module FieldQuery
  # Builds the query based on input to search fields
  def build_search_query
    # If searching by date
    if get_field_type == "Date"
      queryhash = {range: { @fieldnames[0] => {gte: @input[:start_date], lte: @input[:end_date]}}}
      
    # If searching by any other field
    elsif @fieldnames[0] != nil
      # Exclude fields that shouldn't be searchable from query
      fields_to_search = @fieldnames[0] == "_all" ? @all_searchable_fields : [@fieldnames[0]]
      
      queryhash = {
        simple_query_string: {
          query: @input[:searchterm],
          fields: fields_to_search,
          default_operator: "AND",
          flags: "AND|OR|PHRASE|PREFIX|NOT|FUZZY|SLOP|NEAR"
        }}
    else
      queryhash = {}
    end

    return queryhash
  end

  # Gets the type of a field                                                                             
  def get_field_type
    field_type = ""

    # Go through only the appropriate fields for query
    use_all_or_some("field_info", @all_field_info).each do |f|
      if @input[:field].to_s == f["Field Name"]
        field_type = f["Type"]
      end
    end
    return field_type
  end

  # Combine search and facet queries based on if it is search and facets, just search, just facets  
  def combine_search_and_facet_queries(queryhash, filterhash)
    #TODO:facets => Use the bool query instead with a must clause for the query and a filter clause for the filter.
    if @filter_by.empty? && queryhash.empty?
      fullhash = { 'match_all': {} }
    elsif !@filter_by.empty? && !queryhash.empty?
      fullhash = { filtered: { query: queryhash, filter: filterhash }}
    elsif queryhash.empty?
      fullhash = { filtered: { filter: filterhash}}
    else
      fullhash = queryhash
    end
    return fullhash
  end
end
