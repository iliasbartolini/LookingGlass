module ControllerUtils
  # Calculate start and page num
  def page_calc(params)    
    pagenum = params[:page] ? params[:page].to_i : 1
    start = pagenum*30-30

    return pagenum, start
  end

  # Count the number of docs across all models
  def get_total_docs
    @models.inject(0) { |sum, m| sum + m.count }
  end
end
