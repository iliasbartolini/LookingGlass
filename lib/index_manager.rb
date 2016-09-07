require 'open-uri'
require 'pry'
require 'datapackage.rb'
load 'generate_id.rb'
load 'date_funcs.rb'
load 'misc_process.rb'
load 'process_data.rb'
load 'import_support.rb'
load 'multi_dataset.rb'
load 'version_tracking.rb'
load 'tag_processor.rb'

class IndexManager
  include ENAnalyzer
  extend GenerateId
  extend DateFuncs
  extend MiscProcess
  extend ProcessData
  extend ImportSupport
  extend MultiDataset
  extend ClassGen
  extend FacetsQuery
  extend VersionTracking
  extend TagProcessor
  include MiscProcess

  # Index creation
  def self.create_index(dataspec, model_name, options={})
    # Make client, get settings, set name
    doc_class = ClassGen.gen_class(model_name, dataspec)
    client = doc_class.gateway.client

    # Delete index if it already exists
    client.indices.delete index: dataspec.index_name rescue nil if options[:force]

    settings = ENAnalyzer.analyzerSettings
    mappings = doc_class.mappings.to_hash

    # Create index with appropriate settings and mappings
    client.indices.create index: dataspec.index_name,
    body: {
      settings: settings.to_hash,
      mappings: mappings.to_hash }
    
    return doc_class
  end

  # Import data from different formats
  def self.import_data(options={})
    # Load all datasets and make indexes for them
    @importer = Rails.application.config.x.importer.instance_config
    load_everything

    @dataspecs.each do |dataspec|
      doc_class = create_index(dataspec, gen_class_name(dataspec), force: true)
      
      # Import from directory
      Dir.glob(dataspec.data_path+"/**/*.json") do |file|
        if !file.include? dataspec.ignore_ext
          begin
            importFileInDir(file, dataspec, doc_class)
          rescue
          end
        end
      end
    end
  end
end
