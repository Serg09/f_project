require 'resque/tasks'
require 'resque/scheduler/tasks'

namespace :resque do
  task setup: :environment do
    require 'resque'
    #TODO  add redis cloud initialization
  end

  task setup_schedule: :environment do
    require 'resque-scheduler'
    config = YAML.load_file(Rails.root.join('config', 'task_schedule.yml'))
    Resque.schedule = config[Rails.env]
  end

  task scheduler: :setup_schedule
end
