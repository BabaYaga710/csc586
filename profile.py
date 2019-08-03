import geni.portal as portal
import geni.rspec.pg as rspec
import geni.rspec.pg as pg
import geni.rspec.igext as IG

pc = portal.Context()
request = pc.makeRequestRSpec()

tourDescription = \
"""
This profile provides a two-node set to study SSO. One node will be the LDAP server, and the other node is a client who is to be authenticated using LDAP. 
"""

tour = IG.Tour()
tour.Description(IG.Tour.TEXT,tourDescription)
request.addTour(tour)
prefixForIP = "192.168.1."
link = request.LAN("lan")

for i in range(2):
  if i == 0:
    node = request.XenVM("ldapserver") 
    sudo apt-get install /local/repository/slapd.sh
  else:
    node = request.XenVM("ldapclient")
   
  node.routable_control_ip = "true"  
  node.disk_image = "urn:publicid:IDN+emulab.net+image+emulab-ops:UBUNTU18-64-STD"
  iface = node.addInterface("if" + str(i))
  iface.component_id = "eth1"
  iface.addAddress(pg.IPv4Address(prefixForIP + str(i + 1), "255.255.255.0"))
  link.addInterface(iface)

#node.addService(pg.Execute(shell="sh", command="/local/repository/slapd.sh"))
#

  
# Print the RSpec to the enclosing page.
pc.printRequestRSpec(request)


