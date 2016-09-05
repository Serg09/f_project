require 'resque/tasks'
require 'resque/scheduler/tasks'

namespace :resque do
  task setup: :environment do
    require 'resque'
    #TODO  add redis cloud initialization
  end

  task :setup_schedule do
    require 'resque-scheduler'
    Resque.schedule = YAML.load_file(Rails.root.join('config', 'task_schedule.yml'))
  end

  task scheduler: :setup_schedule
end
