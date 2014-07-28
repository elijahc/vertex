require 'ap'

class SleepJob
  include Sidekiq::Worker
  include Sidekiq::Status::Worker

  def perform(options={})

    length = options.has_key?('length') ? options['length'].to_i : 100
    total(length)
    num = 0
    while num < length
      at(num, "At #{num} of #{options['length']}")
      sleep(0.1)
      num += 1
    end
  end
end
