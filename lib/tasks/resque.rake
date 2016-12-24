namespace :resque do
  task setup: :environment do
    require 'resque'
  end

  task setup_schedule: :environment do
    require 'resque-scheduler'
    config = YAML.load_file(Rails.root.join('config', 'task_schedule.yml'))
    Resque.schedule = config[Rails.env]
    Rails.logger.info "Configured Resque with the following schedule: #{Resque.schedule.inspect}"
  end

  task scheduler: :setup_schedule
end
