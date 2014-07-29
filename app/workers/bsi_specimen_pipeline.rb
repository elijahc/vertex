class BsiSpecimenPipeline < Pipeline::Base
  include Pipeline::BSI::Importer
  include Pipeline::BSI::Model::CustomFields
  include Sidekiq::Worker
  include Sidekiq::Status::Worker
  sidekiq_options :retry => false
  REQUIRED_PARAMS = {
    'bsi_username' => 'text_field',
    'bsi_password' => 'password_field',
    'bsi_instance' => 'text_field',
  }

  def perform(options)
    total 100

    at 10, 'Setting up...'

    options.store('model_options',{:custom_fields => bsi_specimen_fields})

    ap options

    key = {
      :user   => options['bsi_username'],
      :pass   => options['bsi_password'],
      :server => 'PCF'
    }

    run = Run.find(options['run_id'])
    file_path = "public/"+options['specimen_file']['file']['url']

    self.parser   = Module.const_get("Pipeline::Parser::#{run.job.parser}").new
    self.importer = SpecimenImporter.new(key, instance: options['instance'])

    at 20, 'Parsing...'
    specimens = parse(file_path, options)

    at 60, 'Importing...'
    import(specimens, options)

    at 100, 'Job Complete'
  end

  def self.required_prompts
    REQUIRED_PARAMS
  end
end
