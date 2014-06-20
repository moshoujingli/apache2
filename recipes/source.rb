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

remote_file "#{Chef::Config[:file_cache_path]}/php-#{version}.tar.gz" do
  source "#{node['apache']['url']}/httpd-#{version}.tar.gz"
  checksum node['apache']['checksum']
  mode '0644'
  not_if "which #{node['apache']['bin']}"
end

bash 'build apache' do
  cwd Chef::Config[:file_cache_path]
  code <<-EOF
  tar -zxf apache-#{version}.tar.gz
  (cd apache-#{version} && #{ext_dir_prefix} ./configure #{configure_options})
  (cd apache-#{version} && make && make install)
  EOF
  not_if "which #{node['apache']['bin']}"
end