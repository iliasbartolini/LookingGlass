# -*- coding: utf-8 -*-
module CategoryLink
  # Generate link html for single term                                                                              
  def termLink(val, categories_chosen, category_name)
    linkname = "#{val['key']} (#{val['doc_count'].to_s})"

    # Only generate links for non-blank terms
    if !val['key'].empty?
      # Check if link is selected or not                                                                    
      if is_selected?(categories_chosen, val)
        return selected(val, categories_chosen, category_name, linkname)
      else
        return notSelected(val, categories_chosen, category_name, linkname)
      end
    end
  end

  # Check if facet is selected                                                                    
  def is_selected?(categories_chosen, val)
    single_match = categories_chosen == val['key']
    multiple_match = (categories_chosen.is_a?(Array) && categories_chosen.include?(val['key']))
    return single_match || multiple_match
  end

  # New search path for facet (to avoid pagination issue)
  def prepNewPath(par, category_name, chosen)
    search_params = par.symbolize_keys.merge(category_name.to_sym => chosen, :page => 1)
    return search_path(search_params)
  end

  # Generate link for selected facet
  def selected(val, categories_chosen, category_name, linkname)
    # Check if there are other facets selected (in this category or others)
    if params.except("controller", "action", "utf8", "page", category_name).length > 0 || categories_chosen.is_a?(Array)
      # Are there other facets selected in this category?
      if categories_chosen.is_a?(Array)
        genMultSelected(val, categories_chosen, linkname, category_name)
      else # If no others in category selected
        search_params = params.symbolize_keys.except(category_name.to_sym, :page)
        return genLink(linkname, search_path(search_params), true)
      end
    else # If no others selected
      return genLink(linkname, root_path, true)
    end
  end

  # Handles generation of links for facets when multiple values are selected 
  def genMultSelected(val, categories_chosen, linkname, category_name)
    outval = categories_chosen.dup
    outval.delete(val['key'])
    outval = outval[0] if categories_chosen.count <= 2
    return genLink(linkname, prepNewPath(params.except(category_name), category_name, outval), true)
  end


  # If facet is not selected, generate link 
  def notSelected(val, categories_chosen, category_name, linkname)
    if categories_chosen # Check if another facet in the same category is selected
      return pickMeToo(categories_chosen, val, category_name, linkname)
    else
      return pickMeFirst(val, category_name, linkname)
    end
  end

  # Generates link if no others are picked in category 
  def pickMeFirst(val, category_name, linkname)
    val_link = genLink(linkname, prepNewPath(params, category_name, val['key']), false)
    params.except(category_name)

    return val_link
  end

  # Generates link for if other vals in category are chosen (but not this one yet)
  def pickMeToo(categories_chosen, val, category_name, linkname)
    # Handle multiple categories chosen vs one
    if categories_chosen.is_a?(Array)
      categories_chosen = categories_chosen.dup.push(val['key'])
    else
      categories_chosen = [categories_chosen, val['key']]
    end

    # Generate link
    val_link = genLink(linkname, prepNewPath(params, category_name, categories_chosen), false)
    params.except(category_name).merge(category_name => categories_chosen)

    return val_link
  end
end
