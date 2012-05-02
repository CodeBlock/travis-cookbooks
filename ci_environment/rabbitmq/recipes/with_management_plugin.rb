#
# Cookbook Name:: rabbitmq
# Recipe:: with_management_plugin
#

include_recipe "rabbitmq::default"

case node[:platform]
when "ubuntu", "debian"
  # RabbitMQ 2.7.0 and later ship with plugins bundled, so we just have
  # to activate them using rabbitmq-plugins. MK.
  # Unfortunately Fedora doesn't have 2.7.0 or later. -CodeBlock.
  bash "enable rabbitmq management plugin" do
    user "root"
    code "rabbitmq-plugins enable rabbitmq_management"

    notifies :restart,  resources(:service => "rabbitmq-server"), :immediately
  end
end
