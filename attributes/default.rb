# errbit config
default['errbit']['config']['host'] = "errbit.example.com"
default['errbit']['config']['port'] = "80"

if node['errbit_port']
  default['errbit']['config']['port'] = node['errbit_port']
end

if node['errbit_host']
  default['errbit']['config']['host'] = node['errbit_host']
end
