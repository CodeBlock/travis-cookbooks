#
# Cookbook Name:: rvm
# Recipe:: default
# Copyright 2011-2012, Travis CI development team
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

# Make sure that the package list is up to date on Ubuntu/Debian.
include_recipe "apt" if ['debian', 'ubuntu'].member? node[:platform]

# Make sure we have all we need to compile ruby implementations:
include_recipe "networking_basic"
include_recipe "build-essential"
include_recipe "git"
include_recipe "libyaml"
include_recipe "libgdbm"
include_recipe "libreadline"
include_recipe "libxml"
include_recipe "libssl"
include_recipe "libncurses"

bash "install RVM" do
  user        node.travis_build_environment.user
  cwd         node.travis_build_environment.home
  environment Hash['HOME' => node.travis_build_environment.home, 'rvm_user_install_flag' => '1']
  code        <<-SH
  curl -s https://raw.github.com/wayneeseguin/rvm/master/binscripts/rvm-installer -o /tmp/rvm-installer
  chmod +x /tmp/rvm-installer
  /tmp/rvm-installer --version #{node.rvm.version}
  ~/.rvm/bin/rvm version
  SH
  not_if      "test -d #{node.travis_build_environment.home}/.rvm"
end

cookbook_file "/etc/profile.d/rvm.sh" do
  owner node.travis_build_environment.user
  group node.travis_build_environment.group
  mode 0755
end

cookbook_file "#{node.travis_build_environment.home}/.rvmrc" do
  owner node.travis_build_environment.user
  group node.travis_build_environment.group
  mode  0755

  source "dot_rvmrc.sh"
end

# Fedora 16 (and 15) has a hard time building RVMified ruby18.
# Later on we will want to make this (and :fedora_arguments from multi.rb)
# check and make sure that we are on <17. -CodeBlock.
if node[:platform] == 'fedora'
  cookbook_file "#{node.travis_build_environment.home}/.stdout-rouge-fix.patch" do
    owner node.travis_build_environment.user
    group node.travis_build_environment.group
    mode  0755
    source "stdout-rouge-fix.patch"
  end
end
