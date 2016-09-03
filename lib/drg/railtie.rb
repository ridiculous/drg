class DRG::Railtie < Rails::Railtie
  rake_tasks do
    load 'tasks/drg.rake'
  end
end
