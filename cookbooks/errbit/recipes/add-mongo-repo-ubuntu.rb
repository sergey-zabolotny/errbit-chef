bash 'Add mongodb repo' do
  code <<-EOH
  curl -sSL https://www.mongodb.org/static/pgp/server-4.4.asc | apt-key add - \
  && sys_codename=$(. /etc/os-release; echo $VERSION_CODENAME) \
  && echo "deb [ arch=amd64,arm64 ] http://repo.mongodb.org/apt/#{node['platform']} ${sys_codename}/mongodb-org/4.4 multiverse" | tee /etc/apt/sources.list.d/mongodb-org.list
  EOH
end
