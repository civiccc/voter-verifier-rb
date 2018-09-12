require 'rake'

RSpec.shared_context 'rake' do
  let(:project_root) { File.expand_path('../../..', __dir__) }

  let(:task_name) { self.class.description }
  let(:task_path) { "lib/tasks/#{task_name.split(':').first}" }
  let(:task_args) { [] }

  subject { Rake::Task[task_name].invoke(*task_args) }

  # Silence ProgressBar (if used)
  before { stub_const('ProgressBar::Output::DEFAULT_OUTPUT_STREAM', StringIO.new) }

  around do |example|
    original_rake_application = Rake.application
    Rake.application = Rake::Application.new
    Rake.application.rake_require(task_path, [project_root], [])
    Rake::Task.define_task(:environment)

    example.run

    Rake.application = original_rake_application
  end
end
