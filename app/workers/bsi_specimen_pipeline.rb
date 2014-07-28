class BsiSpecimenPipeline < Pipeline::Base
  include Pipeline::BSI::Importer
  include Pipeline::BSI::Model::CustomFields
  include Sidekiq::Worker
  include Sidekiq::Status::Worker
  sidekiq_options :retry => false


  def perform(options)
    total 100

    at 10, 'Setting up...'

    options.store('model_options',{:custom_fields => bsi_specimen_fields})

    ap options

    key = {
      :user   => 'ecog_bot',
      :pass   => ENV['ECOG_BOT_PASS'],
      :server => 'PCF',
      :url    => 'https://websvc-mirror.bsisystems.com:2271/bsi/xmlrpc'
    }

    run = Run.find(options['run_id'])
    file_path = "public/"+options['specimen_file']['file']['url']

    self.parser   = Module.const_get("Pipeline::Parser::#{run.job.parser}").new
    self.importer = SpecimenImporter.new(key)

    at 20, 'Parsing...'
    specimens = parse(file_path, options)
    at 60, 'Importing...'
    import(specimens, options)

    at 100, 'Job Complete'
  end
end
