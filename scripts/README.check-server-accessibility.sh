check-server-accessibility.sh
-----------------------------

This bash script is designed to check an accessibility of servers to be the members of
virtual storage cluster using command 'ping'

This script is run with the following input parameters:

check-server-accessibility.sh  <servers list file>   [-c count] [-s packetsize]

where:

     <servers list file> -- file name contaning servers' FQDN names (ip addresses), one name per line
     -c count            -- a count of ping packets (default 5) 
     -s packetsize       -- a ping packet size (default 1024 bytes)



It is supposed that virtual network infrastucture connecting the servers of virtual storage cluster to be made is
already built.

This script returns zero exit status, if all servers are accessible and  non-zero exit status, if at least
one server is not accessible
The file <servers list file> can have comment lines beginning with '#'
