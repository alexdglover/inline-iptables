#
# Cookbook Name:	inline-iptables
# Recipe: 		default
# Author:		Alex D Glover (alex@alexdglover.com)
# Description:		A recipe to manage iptables without impacting existing 
#			iptables rules or chains, and allowing individual
#			inbound/outbound ports as well as port ranges to be 
#			managed with programmatic ease.
# Dependencies:		attributes/inline-iptables.rb
# Usage:		Set the ["inline-iptables"]["listen_ports"] and/or
#			["inline-iptables"]["outbound_ports"] attributes at the
#			node or role level



# Grab the comma separated list of ports that need to be open.
# Keep in mind these attribute could be set by a role, recipe, or node override
listen_ports      = node["inline-iptables"]["listen_ports"]
outbound_ports    = node["inline-iptables"]["outbound_ports"]

# Boolean variable to track if we a change has been made
iptables_modified = false

# Debug friendly logging
Chef::Log.info <<-EOS

Entering ondemand_base::iptables_manager {
  listen_ports        = #{listen_ports}
  outbound_ports      = #{outbound_ports}
}
EOS

# Read the current iptables data
iptables_content = File.read("/etc/sysconfig/iptables")

# If the list of ports is the empty string, do nothing
unless listen_ports == ""
  
  # We are creating a new iptables chain called App-INPUT; if it already
  # exists, don't create it again
  unless iptables_content.include?(":App-INPUT - [")
    execute "create new INPUT chain" do
      command "iptables -N App-INPUT;"
    end
    iptables_modified = true
  end
  
  # Break our port list into an array
  listen_ports_array = listen_ports.split(',')

  # For each port that needs to be opened, insert the corresponding rule
  # into our chain, but only if doesn't exist already
  listen_ports_array.each do |port|
    unless iptables_content.include?("-A App-INPUT -p tcp -m tcp --dport #{port} -j ACCEPT")
      execute "add input rule to iptables for port #{port}" do
        command "iptables -I App-INPUT -p tcp --dport #{port} -j ACCEPT"
      end
      iptables_modified = true
    end
  end

  # Connect our App-INPUT chain to the generic INPUT chain
  unless iptables_content.include?("-A INPUT -j App-INPUT")
    execute "connect App-INPUT to INPUT chain" do
      command "iptables -I INPUT -j App-INPUT"
    end
    iptables_modified = true
  end
  
  # Connect our App-INPUT chain to the generic FORWARD chain
  unless iptables_content.include?("-A FORWARD -j App-INPUT")
    execute "connect App-INPUT to FORWARD chain" do
      command "iptables -I FORWARD -j App-INPUT"
    end
    iptables_modified = true
  end

else
  Chef::Log.info "No listen ports specified to be opened"
end

# If the list of ports is the empty string, do nothing
unless outbound_ports == ""
  
  # We are creating a new iptables chain called App-OUTPUT; if it already
  # exists, don't create it again
  unless iptables_content.include?(":App-OUTPUT - [")
    execute "create new OUTPUT chain" do
      command "iptables -N App-OUTPUT;"
    end
    iptables_modified = true
  end

  # Break our port list into an array
  outbound_ports_array = outbound_ports.split(',')

  # For each port that needs to be opened, insert the corresponding rule
  # into our chain, but only if doesn't exist already
  outbound_ports_array.each do |port|
    execute "add input rule to iptables for port #{port}" do
      command "iptables -I App-OUTPUT -p tcp --dport #{port} -j ACCEPT"
      only_if {!iptables_content.include?("-A App-OUTPUT -p tcp -m tcp --dport #{port} -j ACCEPT")}
    end
    iptables_modified = true
  end
  
  # Connect our App-OUTPUT chain to the generic OUTPUT chain
  unless iptables_content.include?("-A OUTPUT -j App-OUTPUT")
    execute "connect App-OUTPUT to OUTPUT chain" do
      command "iptables -I OUTPUT -j App-OUTPUT"
    end
    iptables_modified = true
  end

else
Chef::Log.info "No outbound ports specified to be opened"
end

if iptables_modified
  
  execute "save updated iptables" do
    command "/etc/init.d/iptables save"
  end

  service "iptables" do
    action :restart
    ignore_failure true
  end
else
  Chef::Log.info "No changes made, not restarting iptables"
end

