require 'bundler/gem_tasks'

Dir['tasks/**/*.rake'].each { |t| load t }

upstream = Gem::Specification.find_by_name('rubocop')

desc "Vendor rubocop-#{upstream.version} configuration into gem"
task :vendor do
  src = Pathname.new(upstream.gem_dir).join('config')
  dst = Pathname.new(__FILE__).dirname.join('config')

  mkdir_p dst
  cp(src.join('default.yml'), dst.join('upstream.yml'))

  require 'rubocop'
  require 'yaml'
  cfg = RuboCop::Cop::Cop.all.each_with_object({}) { |cop, acc| acc[cop.cop_name] = { 'Enabled' => false }; }
  File.open(dst.join('disable_all.yml'), 'w') { |fh| fh.write cfg.to_yaml }

  sh %(git add #{dst}/{upstream,disable_all}.yml)
  sh %(git commit -m "Vendor rubocop-#{upstream.version} upstream configuration.")
end

require 'cookstyle'
desc "Run cookstyle against cookstyle"
task :style do
  sh('bundle exec cookstyle')
end

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/cop/**/*.rb']
end

desc 'Run RSpec with code coverage'
task :coverage do
  ENV['COVERAGE'] = 'true'
  Rake::Task['spec'].execute
end

desc 'Ensure that all cops are defined in the cookstyle.yml config'
task :validate_config do
  require 'cookstyle'
  require 'yaml'
  status = 0
  config = YAML.load_file('config/cookstyle.yml')

  puts 'Checking that all cops are defined in config/cookstyle.yml:'

  RuboCop::Cop::Chef.constants.each do |dep|
    RuboCop::Cop::Chef.const_get(dep).constants.each do |cop|
      unless config["#{dep}/#{cop}"]
        puts "Error: #{dep}/#{cop} not found in config/cookstyle.yml"
        status = 1
      end
    end
  end

  puts 'All Cops found in the config. Good work.' if status == 0

  exit status
end

begin
  require 'yard'
  YARD::Rake::YardocTask.new(:docs)
rescue LoadError
  puts 'yard is not available. bundle install first to make sure all dependencies are installed.'
end

task :console do
  require 'irb'
  require 'irb/completion'
  ARGV.clear
  IRB.start
end
task default: [:style, :spec, :validate_config]
