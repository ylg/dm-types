require 'rubygems'

# TODO: autovalidation hooks are needed badly,
#       otherwise plugin devs will have to abuse
#       alising and load order even further and it kinda makes
#       me sad -- MK

# use local dm-core if running from a typical dev checkout.
lib = File.join('..', 'dm-core', 'lib')
$LOAD_PATH.unshift(lib) if File.directory?(lib)
require 'dm-core'

# grab spec helpers from dm-core clone
lib = File.join('..', 'dm-core', 'lib/dm-core/spec/lib')
$LOAD_PATH.unshift(lib) if File.directory?(lib)
require 'pending_helpers'
require 'adapter_helpers'

# use local dm-validations if running from a typical dev checkout.
lib = File.join('..', 'dm-validations', 'lib')
$LOAD_PATH.unshift(lib) if File.directory?(lib)
require 'dm-validations'

# Support running specs with 'rake spec' and 'spec'
$LOAD_PATH.unshift('lib') unless $LOAD_PATH.include?('lib')

require 'dm-types'

SPEC_ROOT = Pathname(__FILE__).dirname.expand_path

DEPENDENCIES = {
  'bcrypt' => 'bcrypt-ruby',
}

adapters  = ENV['ADAPTERS'].split(' ').map { |adapter_name| adapter_name.strip.downcase }.uniq
adapters  = DataMapper::Spec::AdapterHelpers.primary_adapters.keys if adapters.include?('all')

DataMapper::Spec::AdapterHelpers.setup_adapters(adapters)

def try_spec
  begin
    yield
  rescue NameError
    # do nothing
  rescue LoadError => error
    raise error unless lib = error.message.match(/\Ano such file to load -- (.+)\z/)[1]

    gem_location = DEPENDENCIES[lib] || raise("Unknown lib #{lib}")

    warn "[WARNING] Skipping specs using #{lib}, please do: gem install #{gem_location}"
  end
end

Spec::Runner.configure do |config|
  config.extend(DataMapper::Spec::AdapterHelpers)
  config.include(DataMapper::Spec::PendingHelpers)
end
