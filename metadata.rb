name              "inline-iptables"
maintainer        "Alex D Glover"
maintainer_email  "alex@alexdglover"
license           "GPL 2.0"
description       "An iptables cookbook built to be flexible in it's application through attributes or wrapper recipes."
version           "0.0.2"

recipe "iptables", "An iptables cookbook built to be flexible in it's application through attributes or wrapper recipes"
%w{redhat centos oracle}.each do |os|
  supports os
end
