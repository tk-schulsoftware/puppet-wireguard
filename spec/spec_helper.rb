require 'puppetlabs_spec_helper/module_spec_helper'
require 'rspec-puppet-facts'

require 'spec_helper_local' if File.file?(File.join(File.dirname(__FILE__), 'spec_helper_local.rb'))

include RspecPuppetFacts

default_facts = {
  puppetversion: Puppet.version,
  facterversion: Facter.version,
}

default_fact_files = [
  File.expand_path(File.join(File.dirname(__FILE__), 'default_facts.yml')),
  File.expand_path(File.join(File.dirname(__FILE__), 'default_module_facts.yml')),
]

default_fact_files.each do |f|
  next unless File.exist?(f) && File.readable?(f) && File.size?(f)

  begin
    default_facts.merge!(YAML.safe_load(File.read(f), [], [], true))
  rescue => e
    RSpec.configuration.reporter.message "WARNING: Unable to load #{f}: #{e}"
  end
end

# read default_facts and merge them over what is provided by facterdb
default_facts.each do |fact, value|
  add_custom_fact fact, value
end

RSpec.configure do |c|
  # getting the correct facter version is tricky. We use facterdb as a source to mock facts
  # see https://github.com/camptocamp/facterdb
  # people might provide a specific facter version. In that case we use it.
  # Otherwise we need to match the correct facter version to the used puppet version.
  # as of 2019-10-31, puppet 5 ships facter 3.11 and puppet 6 ships facter 3.14
  # https://puppet.com/docs/puppet/5.5/about_agent.html
  c.default_facter_version = if ENV['FACTERDB_FACTS_VERSION']
                               ENV['FACTERDB_FACTS_VERSION']
                             else
                               Gem::Dependency.new('', ENV['PUPPET_VERSION']).match?('', '5') ? '3.11.0' : '3.14.0'
                             end

  c.hiera_config = File.expand_path(File.join(__FILE__, '../fixtures/hiera.yaml'))
  c.mock_framework = :rspec
end

# 'spec_overrides' from sync.yml will appear below this line
