#
# Author:: Thomas Rampelberg <thomas@saunter.org>
# Cookbook Name:: glue
# Provider:: git
#
# Copyright 2011, BitTorrent Inc.
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

require 'chef/mixin/command'
require 'chef/mixin/language'
include Chef::Mixin::Command

action :sync do
  user = data_bag_item('glue', new_resource.user)

  %w{bin keys}.each do |dir|
    directory "/opt/glue/#{dir}" do
      recursive true
      owner "root"
      mode "0600"
    end
  end

  file "/opt/glue/keys/#{new_resource.user}.pem" do
    backup false
    mode "0600"
    owner "root"
    content user['key']
  end

  template "/opt/glue/bin/#{new_resource.user}.sh" do
    mode "0744"
    owner "root"
    source "wrapper.sh.erb"
    cookbook "glue"
    variables(
        :user => new_resource.user
              )
  end

  repo_sync = Chef::Resource::Git.new(new_resource.path, run_context)
  repo_sync.repository( new_resource.repository )
  repo_sync.revision( new_resource.revision )
  repo_sync.ssh_wrapper( "/opt/glue/bin/#{new_resource.user}.sh" )
  repo_sync.depth( 5 )
  repo_sync.run_action(:sync)

  @new_resource.updated_by_last_action(true) if repo_sync.updated?

end
