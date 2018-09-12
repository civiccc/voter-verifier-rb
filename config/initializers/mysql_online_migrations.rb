if ActiveRecord.version.to_s != '5.1.6'
  raise 'Check the monkey patch for ActiveRecord::Tasks::MySQLDatabaseTasks still works!'
end

module ActiveRecord
  module ConnectionAdapters
    module SchemaStatements
      module WithSafeMigration
        # Assume all CREATE TABLE statements are safe to migrate, since they
        # contain no data and thus a lock will not block for long.
        #
        # This saves us from having to use the `safe_migration` helper in cases
        # where it's not necessary (from a practical perspective).
        def create_table(*args, &block)
          ActiveRecord::BrigadeMigrationHelpers.safe_migration do
            super(*args, &block)
          end
        end
      end

      prepend WithSafeMigration
    end
  end

  class Migration
    module BrigadeMigrationHelpers
      module_function

      # Mark a collection of migrations as unsafe to run in production-like
      # environments.
      #
      # For example, if you have a migration like the following:
      #
      #     def change
      #       add_index :my_table, :my_column
      #     end
      #
      # ...if that migration requires a pt-online-schema-change, you would change
      # it to:
      #
      #     def change
      #       manual_migration do
      #         add_index :my_table, :my_column
      #       end
      #     end
      #
      # This will allow you to run the migrations in the development/test
      # environments, but it will skip running the migrations in production-like
      # environments (you'll have to run pt-online-schema-change manually in those
      # environments).
      #
      # For detailed instructions on how to run pt-online-schema-change,
***REMOVED***
      def manual_migration(&block)
        # In non-production environments, we want to be able to run the
        # migration without error if it is run within a `manual_migration`
        # block, as this serves as a reminder to the developer that they need to
        # run the migration with pt-online-schema-change manually in
        # production-like environments.
        safe_migration(&block) if %w[test development].include?(Rails.env)

        # In production-like environments, we don't run the migrations at all
      end

      # Marks a block of migrations as safe to migrate, even in production-like
      # environments.
      #
      # This is useful when you are creating a table for the first time or if you
      # "know" that an exclusive lock will not be an issue (since the table is
      # very small or otherwise--make sure you know for certain!).
      def safe_migration
        original_value = ActiveRecord::Base.mysql_online_migrations
        begin
          ActiveRecord::Base.mysql_online_migrations = false
          yield
        ensure
          ActiveRecord::Base.mysql_online_migrations = original_value
        end
      end
    end

    include BrigadeMigrationHelpers
  end

  # Raised when a migration would be run that requires running
  # pt-online-schema-change, since MySQL's built-in online DDL can't execute the
  # statement without obtaining a lock.
  #
  # @see https://dev.mysql.com/doc/refman/5.6/en/innodb-create-index-overview.html
  class PTOnlineSchemaChangeRequired < ActiveRecordError; end

  module Tasks
    module DatabaseTasks
      module WithExceptionHandling
        def self.prepended(base)
          base.singleton_class.prepend ModuleMethods
        end

        module ModuleMethods
          # Override the default migrate task to display a more-informative error
          # message when a pt-online-schema-change is required.
          def migrate
            super
          rescue => ex # rubocop:disable Style/RescueStandardError
            # Sadly, StandardError is raised in this situation, so we have to
            # inspect the message to tell if it's relevant
            if /\bLOCK=NONE is not supported\b/.match? ex.message
              raise(
                PTOnlineSchemaChangeRequired,
                "\n----------------------------------------------------------------------------" \
                "\nMigration requires a pt-online-schema-change!" \
***REMOVED***
                "\n\nIf you are sure this migration is safe, wrap it with `safe_migration" \
                "\n----------------------------------------------------------------------------\n" +
                  ex.message,
                ex.backtrace,
              )
            end
            raise
          end
        end
      end

      prepend WithExceptionHandling
    end

    class MySQLDatabaseTasks
      # Override so we can swap out the user/password used for database
      # migrations. We use a different user in production so we don't
      # accidentally kill long-running queries for migrations.
      def initialize(configuration)
        if (migration_url = configuration['migration_url'])
          uri = URI.parse(migration_url)
          configuration['username'] = uri.user
          configuration['password'] = uri.password
        end
        @configuration = configuration
      end
    end
  end
end
