require 'rbc'
require 'forwardable'
require 'logger'
#require_relative './pipeline/models/specimen.rb'
#require_relative './pipeline/parsers/fzw_specimen_parser.rb'
#require_relative './pipeline/formatters/fzw_specimen_formatter.rb'
#require_relative './pipeline/importers/specimen_resque.rb'
#require_relative './pipeline/importers/subject_resque.rb'

class Asylum
  # Mixin added functionality
  include Sidekiq::Worker
  include Sidekiq::Status::Worker
  extend Forwardable
  sidekiq_options :retry => false

  @queue = :migration

  attr_accessor :piper
  def_delegators :@piper, :import, :add

  def perform(options)
    at(10, "Initializing")

    startup(options)

    $LOG.debug "Creating spawn batches..."
    run(options['data_file'], options)

    # All jobs submitted, monitor status of submitted jobs
=begin
    jobs_left = Resque.size(@uuid)
    total_jobs = jobs_left
    while jobs_left > 0
      jobs_left = Resque.size(@uuid)
      at(59+(40*(total_jobs-jobs_left)/total_jobs), 100, "Importing...(#{jobs_left} remaining)")
      sleep 1
    end

    $LOG.debug "Trying to kill completed workers"
    system("kill -QUIT #{pid}")
    Resque.remove_queue(@uuid)
=end

    shutdown


    # Called for Resque::Plugins::Status
    completed('downloads' => {
      'failed_rows' => './tmp/failed_rows.csv'
    })
  end

  def startup(options)
    # Initialize Logger
    log_file = File.open("./log/#{options['name']}.log", 'a')
    log_file.sync = true
    $LOG = Logger.new(log_file, 'daily')

    $LOG.debug "Startup phase..."

=begin
    options['dependencies'].each do |dep|
      $LOG.debug "loading #{dep}"
      require "./jobs/lib/#{dep}.rb"
    end
=end


    $LOG.debug "including migration modules"
    begin
      Specimen.send(:include, Formatter)
    rescue NameError
    end

    begin
      Subject.send(:include, Formatter)
    rescue NameError
    end
    self.class.send(:include, Parser)
    self.class.send(:include, Importer)



    $LOG.debug "creating key"
    #bsi_acc = BsiAccount.find(options['bsi_account'])
    #cipher  = Gibberish::AES.new(bsi_acc.username)

    key = {
      :user => options['BSI Username'],
      :pass => options['BSI Password'],
      :url => options['BSI Instance'],
      :server => 'PCF'
    }

    $LOG.debug "Using key: #{key.ai :plain => true}"
    $LOG.info "Initializing Importer..."
    #key[:pass] = cipher.dec(key[:pass])
    @piper = Pipe.new(key, {'queue'=>@uuid}.merge(options))

    $LOG.info "Startup Complete"
  end

  def shutdown
    @piper.terminate
    $LOG.info "Import Job Completed Successfully"
    puts "Job finished Successfully"

    nil
  end

  def run(items_path=nil, options={})
    $LOG.info "Run Phase..."

    if items_path.nil?
      @items = parse(CONFIGS[:file_path])
    else
      $LOG.info "Parsing file"
      at(15, 100, "Parsing file (this may take a while...)")
      @items = parse(items_path, options)
    end


    unless @items.empty?

      total = @items.length

      at(20, 100, "Creating import jobs")

      # Pass import all the items you want and it will get back 1 or many sets of items that need imported
      import(@items, options) do |i, total_batches|
        at(20+(30*i.fdiv(total_batches)), 100, "Building Batch #{i} of #{total_batches}")
      end


    else
      $LOG.debug "No items returned by the parser"
    end

  end

end
