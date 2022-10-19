require 'json'

# import node configuration
node_config = json("/tmp/node.json").params

# extract errbit port
port_number = node_config['default']['errbit']['config']['port']

describe port(port_number) do
  it { should be_listening }
  its('processes') {should include 'ruby'}
end

describe systemd_service('mongod.service') do
  it { should be_installed }
  it { should be_enabled }
  it { should be_running }
end

describe systemd_service('errbit.service') do
  it { should be_installed }
  it { should be_enabled }
  it { should be_running }
end
