#
# Author:: Seth Chisamore (<schisamo@opscode.com>)
# Cookbook Name:: java
# Recipe:: default
#
# Copyright 2008-2011, Opscode, Inc.
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

case node['platform']
when "ubuntu"
  apt_repository "ubuntu-partner" do
    uri "http://archive.canonical.com/ubuntu"
    distribution node['lsb']['codename']
    components ['partner']
    action :add
  end
  # update-java-alternatives doesn't work with only sun java installed
  node.set['java']['java_home'] = "/usr/lib/jvm/java-6-sun"

when "debian"
  apt_repository "debian-non-free" do
    uri "http://http.us.debian.org/debian"
    distribution "stable"
    components ['main','contrib','non-free']
    action :add
  end
  # update-java-alternatives doesn't work with only sun java installed
  node.set['java']['java_home'] = "/usr/lib/jvm/java-6-sun"
when "centos", "redhat", "fedora"
  ["java-1.6.0-openjdk","java-1.6.0-openjdk-devel"].each do |pkg|
    package pkg do
      action :install
    end
  end
else
  Chef::Log.error("Installation of Sun Java packages not supported on this platform.")
end

include_recipe "java::#{node['java']['install_flavor']}"
