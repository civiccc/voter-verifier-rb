require 'active_record'

root_path = File.expand_path('../..', __dir__)

# Rails provides the default seed loader, so we need our own
DummySeedLoader = Class.new do
  def load_seed
    puts 'Seed loading is not implemented, skipping.'
  end
end

namespace :db do
  # override the default db:load_config task to remove rails dependencies
  task load_config: :environment do
    ENV['RAILS_ENV'] = ENV['BRIGADE_ENV'] # some things read this directly :(

    ActiveRecord::Tasks::DatabaseTasks.env = ENV['RAILS_ENV']
    ActiveRecord::Tasks::DatabaseTasks.root = root_path
    ActiveRecord::Tasks::DatabaseTasks.db_dir = "#{root_path}/db"
    ActiveRecord::Tasks::DatabaseTasks.migrations_paths = ["#{root_path}/db/migrate"]
    ActiveRecord::Tasks::DatabaseTasks.database_configuration = ActiveRecord::Base.configurations
    ActiveRecord::Tasks::DatabaseTasks.seed_loader = DummySeedLoader.new
    ActiveRecord::Migrator.migrations_paths = ActiveRecord::Tasks::DatabaseTasks.migrations_paths
  end
end

# pull in AR's full rake task suite
load 'active_record/railties/databases.rake'

# the migration generator lives in Rails; use our own instead
namespace :generate do
  desc 'Generate migration'
  task migration: :environment do
    name = ARGV[1] || raise('Specify name: rake generate:migration your_migration')
    timestamp = Time.now.strftime('%Y%m%d%H%M%S')
    path = "#{root_path}/db/migrate/#{timestamp}_#{name}.rb"
    migration_class = name.split('_').map(&:capitalize).join

    ar_version = "#{ActiveRecord::VERSION::MAJOR}.#{ActiveRecord::VERSION::MINOR}"

    File.open(path, 'w') do |file|
      file.write <<~MIGRATION
        class #{migration_class} < ActiveRecord::Migration[#{ar_version}]
          def change
            # Insert migration code here
          end
        end
      MIGRATION
    end

    puts "Migration #{path} created"
    exit # rake is dumb and interprets the argument as another task to run; cancel that
  end
end

# db:schema:load needs to allow LOCK=SHARED
Rake::Task['db:schema:load'].clear
namespace :db do
  namespace :schema do
    task load: %i[environment load_config check_protected_environments] do
      original_value = ActiveRecord::Base.mysql_online_migrations
      begin
        ActiveRecord::Base.mysql_online_migrations = false
        ActiveRecord::Tasks::DatabaseTasks.load_schema_current(:ruby, ENV['SCHEMA'])
      ensure
        ActiveRecord::Base.mysql_online_migrations = original_value
      end
    end
  end
end
