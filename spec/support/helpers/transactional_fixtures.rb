module RSpec
  module ActiveRecord
    # Ripped straight from https://github.com/rspec/rspec-rails/blob/master/lib/rspec/rails/adapters.rb
    module MinitestLifecycleAdapter
      extend ActiveSupport::Concern

      included do |group|
        group.before { after_setup }
        group.after  { before_teardown }

        group.around do |example|
          before_setup
          example.run
          after_teardown
        end
      end

      def before_setup; end

      def after_setup; end

      def before_teardown; end

      def after_teardown; end
    end

    # Ripped straight from https://github.com/rspec/rspec-rails/blob/master/lib/rspec/rails/adapters.rb
    module SetupAndTeardownAdapter
      extend ActiveSupport::Concern

      module ClassMethods
        # Wraps `setup` calls from within Rails' testing framework in `before` hooks
        def setup(*methods, &block)
          methods.each do |method|
            if method == :setup_fixtures
              prepend_before { __send__ method }
            else
              before { __send__ method }
            end
          end
          before(&block) if block
        end

        # Wraps `teardown` calls from within Rails' testing framework in `after` hooks.
        def teardown(*methods, &block)
          methods.each { |method| after { __send__ method } }
          after(&block) if block
        end
      end

      def initialize(*args)
        super
        @example = nil
      end

      def method_name
        @example
      end
    end

    # Shamelessly adapted from https://github.com/rspec/rspec-rails/blob/master/lib/rspec/rails/fixture_support.rb
    module FixtureSupport
      extend ActiveSupport::Concern
      include SetupAndTeardownAdapter
      include MinitestLifecycleAdapter
      include ::ActiveRecord::TestFixtures

      included do
        self.fixture_path = RSpec.configuration.fixture_path
        self.use_transactional_tests = RSpec.configuration.use_transactional_tests
        self.use_instantiated_fixtures = RSpec.configuration.use_instantiated_fixtures

        def self.fixtures(*args)
          orig_methods = private_instance_methods
          super.tap do
            new_methods = private_instance_methods - orig_methods
            new_methods.each do |method_name|
              proxy_method_warning_if_called_in_before_context_scope(method_name)
            end
          end
        end

        def self.proxy_method_warning_if_called_in_before_context_scope(method_name)
          orig_implementation = instance_method(method_name)
          define_method(method_name) do |*args, &blk|
            if inspect.include?('before(:context)')
              RSpec.warn_with('Calling fixture method in before :context ')
            else
              orig_implementation.bind(self).call(*args, &blk)
            end
          end
        end

        fixtures RSpec.configuration.global_fixtures if RSpec.configuration.global_fixtures
      end
    end

    ::RSpec.configure do |c|
      c.include ::RSpec::ActiveRecord::FixtureSupport

      c.add_setting :use_transactional_tests
      c.add_setting :use_instantiated_fixtures
      c.add_setting :pre_loaded_fixtures
      c.add_setting :global_fixtures
      c.add_setting :fixture_path
      c.add_setting :fixture_table_names
      c.add_setting :fixture_class_names
    end
  end
end
