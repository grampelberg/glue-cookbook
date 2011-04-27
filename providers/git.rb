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

  frec = Chef::Resource::File.new("/opt/glue/keys", run_context)
  frec.path("/opt/glue/keys/#{new_resource.user}.pem")
  frec.backup(false)
  frec.mode("0600")
  frec.owner("root")
  frec.content(user["key"])
  frec.run_action(:create)

  tmpl = Chef::Resource::Template.new("/opt/glue/bin/#{new_resource.user}.sh",
                                      run_context)
  tmpl.mode("0744")
  tmpl.owner("root")
  tmpl.source("wrapper.sh.erb")
  tmpl.cookbook("glue")
  tmpl.variables(
                 :user => new_resource.user
                 )
  tmpl.run_action(:create)

  repo_sync = Chef::Resource::Git.new(new_resource.path, run_context)
  repo_sync.repository( new_resource.repository )
  repo_sync.revision( new_resource.revision )
  repo_sync.ssh_wrapper( "/opt/glue/bin/#{new_resource.user}.sh" )
  repo_sync.depth( 5 )
  repo_sync.run_action(:sync)

  @new_resource.updated_by_last_action(true) if repo_sync.updated?

end
