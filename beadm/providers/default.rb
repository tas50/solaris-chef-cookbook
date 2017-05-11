#
# Copyright (c) 2017, Oracle and/or its affiliates. All rights reserved.
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

include Chef::Mixin::ShellOut

use_inline_resources

def whyrun_supported?
  true
end

def load_current_resource
  @beadm = Chef::Resource.resource_for_node(new_resource.declared_type, run_context.node).new(new_resource.name)
  @beadm.name(new_resource.name)
  @beadm.options(new_resource.options)
  @beadm.mountpoint(new_resource.mountpoint)
  @beadm.new_be(new_resource.new_be)
  @beadm.info(info?)
  @beadm.list(list?)
  @beadm.current_props(current_props?)
end

action :create do
  unless created?
    converge_by "create beadm #{@beadm.name}" do
      beadm_options = ''
      if @beadm.options.empty?
        Chef::Log.info('beadm options not passed')
      else
        Chef::Log.info('beadm options passed')
        @beadm.options.each do |key, val|
          tmp = "-o #{key}=#{val} "
          beadm_options += tmp
        end
      end

      shell_out!("beadm create #{@beadm.name}")

      shell_out!("beadm activate #{@beadm.name}") if @beadm.activate == true
      # update properties for new zfs
      @beadm.info(info?)
      @beadm.current_props(current_props?)
    end
  end
end

action :destroy do
  if created?
    converge_by "destroy beadm #{@beadm.name}" do
      shell_out!("beadm destroy -F #{@beadm.name}")
    end
  end
end

action :destroy_pattern do
  prop_hash = {}
  @beadm.list.stdout.split("\n").each do |line|
    l = line.split(';')
    prop_hash[l[0]] = line
  end
  prop_hash.each do |key, _array|
    bename = key
    next unless bename =~ /#{@beadm.name}/
    converge_by "destroy_pattern beadm #{@beadm.name}" do
      shell_out!("beadm destroy -F #{key}")
    end
  end
end

action :activate do
  if created?
    converge_by "active beadm with beadm activate #{@beadm.name}" do
      shell_out!("beadm activate #{@beadm.name}")
    end
  end
end

action :beadm_publisher_set do
  if created?
    converge_by "mount beadm with beadm mount #{@beadm.name}" do
      shell_out!("beadm activate #{@beadm.name}")
    end
  end
end

action :mount do
  flag = -1
  if created?
    current_be_props = @beadm.current_props[@beadm.name]
    tmp = current_be_props.split(';')
    if tmp[3] == @beadm.mountpoint
      Chef::Log.info("BE already mounted in #{tmp[3]}")
      flag = 0
    elsif tmp[3] != @beadm.mountpoint && tmp[3] != ''
      Chef::Log.info("BE already mounted. Unmount #{tmp[3]}")
      flag = 1
      raise "BE #{@beadm.name} is already mounted in #{tmp[3]}. Please unmount before proceeding."
    else
      converge_by "mount #{@beadm.name} with mountpoint #{@beadm.mountpoint}" do
        status = shell_out!("beadm mount #{@beadm.name} #{@beadm.mountpoint}")
        flag = status.exitstatus
      end
    end
  end

  Chef::Log.info("Mount return value #{flag}")
  flag
end

action :umount do
  if created?
    unless already_mounted?
      converge_by "unmount beadm with beadm umount #{@beadm.name}" do
        shell_out!("beadm umount #{@beadm.name}")
      end
    end
  end
end

action :rename do
  if created?
    converge_by "rename #{@beadm.name} to #{@beadm.new_be}" do
      shell_out!("beadm rename #{@beadm.name} #{@beadm.new_be}")
    end
  end
end

private

def created?
  Chef::Log.info('Checking beadm already created')
  flag = @beadm.info.exitstatus == 0
  flag = false if node['platform_version'] == '5.11' && @beadm.info.stdout.lines.count == 0
  flag
end

def current_props?
  prop_hash = {}
  @beadm.info.stdout.split("\n").each do |line|
    l = line.split(';')
    prop_hash[l[0]] = line
  end
  prop_hash
end

def info?
  Chef::Log.info("Checking info beadm list -H #{@beadm.name}")
  shell_out("beadm list -H #{@beadm.name}")
end

def list?
  Chef::Log.info('Checking beadm list -H')
  shell_out('beadm list -H')
end
