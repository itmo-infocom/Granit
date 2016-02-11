#!/bin/bash
#set -x
#---------------------------------------------------------------+
#                                                               |
# Usage: check-server-accessibility.sh <servers list file>      |
#         [-c count] [-s packetsize]                            |
#                                                               |
# The script is devoted to:                                     |
#                                                               |
#  the scipt is intended to be performed inside storage         |
# cluster  network virtual infrastructure to                    |       
#  check  servers accessibility to be the members of            |
#  virtual storage cluster.                                     |
#                                                               |
#  <server server list file>  is a file name which              |
# contains a list of  servers as FQDN or ip addresses           |
# with one server on a line                                     |
#  -c count         -- a count of ping packets (default 5)      |
#  -s packetsize    -- a ping packet size (default 1024 bytes)  |
#                                                               |
# Creation date:  Mon Feb  8 18:13:11 MSK 2016                  |
# The host where it was developed=pnpi-itmo.pnpi.spb.ru         |
#---------------------------------------------------------------+
#                                                               |
#  Author: A. Oreshkin. email: anatoly.oreshkin@gmail.com       |
#---------------------------------------------------------------+
# History of changes:                                           |
# A. Oreshkin 11.02.2016                                        |
# change                                                        |
# printenv | sed 's/^/export /;s/=/=\"/;s/$/\"/' > /tmp/env_file|
# for                                                           |
# echo "export RC=${RC}" > /tmp/env_file                        |                                                              |
#---------------------------------------------------------------+

export LANG=C

#
#  check  command line parameters
#

if [ "$#" -lt 1 ]; then

    cat <<END

------------------------------------------------------------------------------------------------

  the script '`basename $0`' is designed to check accessibility over network of servers to be the members 
                   of virtual storage cluster 

 Usage: `basename $0`  <servers list file>   [-c count] [-s packetsize] 
       <servers list file> - a file name containing servers'FQDN names (or ip addresses), one name on a line 
       -c count      -- a count of ping packets (default 5)
       -s packetsize -- a ping packet size (default 1024 bytes)
------------------------------------------------------------------------------------------------
END

   exit 1
fi

LOG_FILE=/tmp/`basename $0`-Log-`date +"%Y-%m-%d_%H:%M:%S"`

(

   cat <<END
 Start time =  `date`

END
server_list=$1  # server list file name
count=5       # ping count
packetsize=1024 # ping packet size
export RC=0  # return code

shift
# get command line parameters

while getopts "c:s:" option
do
    case $option in
     c) count=$OPTARG;;
     s) packetsize=$OPTARG;;
     *) echo "Unknown option '$option'. Ignored.";;
    esac
done


    echo "ping parameters: -c ${count} -s ${packetsize}"

#
# check servers accessibility using ping

for server in `cat ${server_list} | grep -v "^#"`
  do
    if ( ping -c ${count} -s ${packetsize} ${server} > /dev/null 2>&1 ); then
       true
#      echo "server ${server} is accessible"
#      echo "------------------------------"
    else 
      echo "server ${server} is NOT accessible"
      echo "----------------------------------"      
      RC=1
    fi
done

   cat <<END
 End time =  `date`"

 End of script `basename $0`
 The Log is available at ${LOG_FILE}
END

# save export RC into /tmp/env_file

echo "export RC=${RC}" > /tmp/env_file
) 2>& 1 | tee ${LOG_FILE}

. /tmp/env_file
rm /tmp/env_file
exit  ${RC}
