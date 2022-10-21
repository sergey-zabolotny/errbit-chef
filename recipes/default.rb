apt_repository 'mongodb' do
  distribution node['lsb']['codename'] + "/mongodb-org/4.4"
  uri 'http://repo.mongodb.org/apt/' + node[:platform]
  components value_for_platform('ubuntu' => {'default' => ['multiverse']},'debian' => {'default' => ['main']})
  arch value_for_platform('ubuntu' => {'default' => 'amd64'})
  key 'https://www.mongodb.org/static/pgp/server-4.4.asc'
end

apt_update do
  action :update
end

# install deps
package [ 'mongodb-org', 'nodejs', 'git']

git '/app' do
  repository 'https://github.com/errbit/errbit.git'
  revision 'main'
  action :sync
end

template "/app/.env" do
  source ".env.erb"
end

bash 'Install ruby and bundler' do
  code <<-EOH
  curl -sSL https://get.rvm.io | bash \
  && usermod -a -G rvm root \
  && source /etc/profile.d/rvm.sh \
  && rvm install ruby-2.7.6 \
  && rvm --default use ruby-2.7.6 \
  && echo "gem: --no-document" >> /etc/gemrc \
  && gem update --system "3.3.21" \
  && gem install bundler --version "2.3.21" \
  && bundle config --global frozen 1 \
  && bundle config --global disable_shared_gems false
  EOH
end

bash 'Build app' do
  code <<-EOH
  bundle install -j "$(getconf _NPROCESSORS_ONLN)" --retry 5 \
  && bundle clean --force \
  && RAILS_ENV=production bundle exec rake assets:precompile \
  && rm -rf /app/tmp/* \
  && chmod 777 /app/tmp
  EOH
  cwd "/app"
  flags "-l"
end

# systemd mongod unit
systemd_unit 'mongod.service' do
  action [:enable, :restart]
end

# systemd errbit unit
systemd_unit 'errbit.service' do
  content <<~EOU
  [Unit]
  Description=Errbit
  After=network.target

  [Service]
  WorkingDirectory=/app
  Environment=HOME=/app
  ExecStart=/bin/bash -l -c "PORT=#{node['errbit']['config']['port']} bundle exec puma -C config/puma.default.rb"
  Restart=always

  [Install]
  WantedBy=multi-user.target
  EOU
  action [:create, :enable, :restart]
end

# save node data
ruby_block "Save node attributes" do
  block do
    File.write("/tmp/node.json", node.to_json)
  end
end
