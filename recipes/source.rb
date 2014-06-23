#
# Author::  BiXiapeng (<bixiaopeng2007@gmail.com>)
# Cookbook Name:: apache2
# Recipe:: source
#
# Copyright 2011, BiXiapeng, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

configure_options = node['apache']['configure_options'].join(' ')

include_recipe 'build-essential'

pkgs = value_for_platform_family(
  %w{ rhel fedora } => %w{ tar pcre-devel zlib-devel },
  %w{ debian ubuntu } => %w{ tar pcre-dev zlib-dev },
  'default' => %w{ tar pcre-dev zlib-dev }
  )

pkgs.each do |pkg|
  package pkg do
    action :install
  end
end

version = node['apache']['version']

remote_file "#{Chef::Config[:file_cache_path]}/httpd-#{version}.tar.gz" do
  source "#{node['apache']['url']}/httpd-#{version}.tar.gz"
  checksum node['apache']['checksum']
  mode '0644'
  not_if "which #{node['apache']['bin']}"
end
#apr
remote_file "#{Chef::Config['file_cache_path']}/apr" do
  source 'http://ftp.riken.jp/net/apache//apr/apr-1.5.1.tar.gz'
  owner 'root'
  group 'root'
  mode "0644"
end


extract 'extract apr' do
  dest "#{Chef::Config['file_cache_path']}/exp/apr/"
  src "#{Chef::Config['file_cache_path']}/apr"
end
#apr-util
remote_file "#{Chef::Config['file_cache_path']}/apr-util" do
  source 'http://ftp.riken.jp/net/apache//apr/apr-util-1.5.3.tar.gz'
  owner 'root'
  group 'root'
  mode "0644"
end


extract 'extract apr-util' do
  dest "#{Chef::Config['file_cache_path']}/exp/apr-util/"
  src "#{Chef::Config['file_cache_path']}/apr-util"
end

bash 'build httpd' do
  cwd Chef::Config[:file_cache_path]
  code <<-EOF
  tar -zxf httpd-#{version}.tar.gz
  mv ./exp/apr httpd-#{version}/srclib/apr
  mv ./exp/apr-util httpd-#{version}/srclib/apr-util
  (cd httpd-#{version} && ./configure #{configure_options})
  (cd httpd-#{version} && make && make install)
  EOF
  not_if "which #{node['apache']['bin']}"
end

bash 'config httpd' do
  code <<-EOF
  head -n1 #{node['apache']['binary']}/apachectl >/etc/init.d/httpd
  echo '# chkconfig: 35 85 15'>>/etc/init.d/httpd
  echo '# description: Activates/Deactivates Apache 2.4.6'>>/etc/init.d/httpd
  tail #{node['apache']['binary']}/apachectl -n +2>>/etc/init.d/httpd
  chkconfig --add httpd
  chkconfig httpd on
  EOF
end