#
# Cookbook Name:	inline-iptables
# Recipe: 		attributes/default.rb
# Author:		Alex D Glover (alex@alexdglover.com)
# Description:		Attributes file to be populated with inbound/outbound ports
# Usage:		Set the node["inline-iptables"]["listen_ports"] and
#			["inline-iptables"]["outbound_ports"] attributes at the
#			node or role level

default["inline_iptables"]["listen_ports"]= ""
default["inline_iptables"]["outbound_ports"]= ""
