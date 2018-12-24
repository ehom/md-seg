require 'yard'

task :default => :doc_dev

YARD::Rake::YardocTask.new :doc_dev do |t|
  t.files   = [ "lib/*.rb", "lib/**/*.rb" ]
  t.options = ["--output", "docs" ]
end
