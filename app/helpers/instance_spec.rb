class InstanceSpec
  attr_reader :site_config, :search_title, :dataspec_paths, :theme, :logo, :favicon, :url_1, :url_2

  # Load importer and vars for search instance
  def initialize
    @path = Rails.application.config.x.importer.instance_config
    get_site_config
  end

  # Gets logo, name, info urls, list of dataspecs, etc
  def get_site_config
    @site_config = JSON.parse(File.read(@path))
    @search_title = @site_config["Search Title"]
    @dataspec_paths = @site_config["Dataset Config"]
    @theme = @site_config["Theme"]
    @logo = @site_config["Logo"]
    @favicon = @site_config["Favicon"]
    @url_1 = @site_config["URL 1"]
    @url_2 = @site_config["URL 2"]
  end
end
