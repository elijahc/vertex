class RubyRunner
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(job_id, prompts={})

    job = Job.find(job_id)

    load_queue = job.dependencies.map{|dep| dep.lib}
    load_queue << job.core
    load_queue.each do |lib|
      require lib.file.current_path
    end

    job = Module.const_get('SleepJob')
  end
end
