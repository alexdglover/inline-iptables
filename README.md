inline-iptables
===============

An iptables cookbook built to be flexible in it's application through attributes or wrapper recipes.

Author
======

Alex D Glover (alex@alexdglover.com)

Description
===========

A recipe to manage iptables without impacting existing iptables rules or chains, and allowing individual inbound/outbound ports as well as port ranges to be managed with programmatic ease. Additionally, this cookbook will insert a new set of chains without affecting any existing iptables chains or rules (hence inline-iptables).


Dependencies
============

None

Usage
=====

Set the ["inline-iptables"]["listen_ports"] and/or ["inline-iptables"]["outbound_ports"] attributes at the node or role level

Compatibility
=============

Tested on RHEL6.4, OEL6.3, CentOS 5.5 and CentOS 6.5

