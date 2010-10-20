require 'rake'
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/test.rb', 'test/test_rails.rb', 'test/test_examples.rb']
  t.verbose = true
end

task :default => "test"


