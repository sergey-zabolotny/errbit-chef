bash 'Add mongodb repo' do
  code <<-EOH
  curl -sSL https://www.mongodb.org/static/pgp/server-4.4.asc | apt-key add - \
  && sys_codename=$(. /etc/os-release; echo $VERSION_CODENAME) \
  && echo "deb http://repo.mongodb.org/apt/#{node['platform']} ${sys_codename}/mongodb-org/4.4 main" | tee /etc/apt/sources.list.d/mongodb-org.list
  EOH
end
