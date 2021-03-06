$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'tmpdir'
require 'bosh/cpi'
require 'cloud/aws'

MOCK_AWS_ACCESS_KEY_ID = 'foo'
MOCK_AWS_SECRET_ACCESS_KEY = 'bar'

def mock_cloud_options
  {
    'plugin' => 'aws',
    'properties' => {
      'aws' => {
        'access_key_id' => MOCK_AWS_ACCESS_KEY_ID,
        'secret_access_key' => MOCK_AWS_SECRET_ACCESS_KEY,
        'region' => 'us-east-1',
        'default_key_name' => 'sesame',
        'default_security_groups' => [],
        'max_retries' => 8,
        'source_dest_check' => false
      },
      'registry' => {
        'endpoint' => 'localhost:42288',
        'user' => 'admin',
        'password' => 'admin'
      },
      'agent' => {
        'foo' => 'bar',
        'baz' => 'zaz'
      }
    }
  }
end

def mock_cloud_properties_merge(override_options)
  mock_cloud_options_merge(override_options, mock_cloud_options['properties'])
end

def mock_cloud_options_merge(override_options, base_hash = mock_cloud_options)
  merged_options = {}
  override_options ||= {}

  override_options.each do |key, value|
    if value.is_a? Hash
      merged_options[key] = mock_cloud_options_merge(override_options[key], base_hash[key])
    else
      merged_options[key] = value
    end
  end

  extra_keys = base_hash.keys - override_options.keys
  extra_keys.each { |key| merged_options[key] = base_hash[key] }

  merged_options
end

def mock_registry(endpoint = 'http://registry:3333')
  registry = double('registry', :endpoint => endpoint)
  allow(Bosh::Cpi::RegistryClient).to receive(:new).and_return(registry)
  registry
end

def mock_cloud(options = nil)
  ec2 = mock_ec2
  allow(AWS::EC2).to receive(:new).and_return(ec2)

  yield ec2 if block_given?

  Bosh::AwsCloud::Cloud.new(options || mock_cloud_options['properties'])
end

def mock_ec2
  ec2 = double(AWS::EC2,
               :instances => double(AWS::EC2::InstanceCollection),
               :volumes => double(AWS::EC2::VolumeCollection),
               :images => double(AWS::EC2::ImageCollection),
               :regions => [ double(AWS::EC2::Region) ])

  yield ec2 if block_given?

  return ec2
end

def dynamic_network_spec
  {
      'type' => 'dynamic',
      'cloud_properties' => {
          'security_groups' => %w[default]
      }
  }
end

def vip_network_spec
  {
    'type' => 'vip',
    'ip' => '10.0.0.1',
    'cloud_properties' => {}
  }
end

def combined_network_spec
  {
    'network_a' => dynamic_network_spec,
    'network_b' => vip_network_spec
  }
end

def resource_pool_spec
  {
    'key_name' => 'test_key',
    'availability_zone' => 'foobar-1a',
    'instance_type' => 'm3.zb'
  }
end

def asset(filename)
  File.expand_path(File.join(File.dirname(__FILE__), 'assets', filename))
end

RSpec.configure do |config|
  config.before do
    logger = Logger.new('/dev/null')
    allow(Bosh::Clouds::Config).to receive(:logger).and_return(logger)
  end
end
