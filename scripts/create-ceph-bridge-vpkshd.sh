#!/bin/bash
#set -x
#---------------------------------------------------------------+
#                                                               |
#  Usage:                                                       |
#                                                               |
# create-ceph-bridge-vpkshd.sh <data center name> <server name> |
#        <server main bridge name> <ceph bridge name> <vlan id> |
#        <ip address/prefix> [comments]                         |
#                                                               |
# The  script is devoted to:                                    |
#                                                               |
#  creating docker ceph ovs bridge on data center server        |
#                                                               |
# Tue Jun 14 14:27:44 MSK 2016                                  |
# The host where it was developed=pnpi-itmo.pnpi.spb.ru         |
#---------------------------------------------------------------+
#                                                               |
#  Author: A. Oreshkin. email: anatoly.oreshkin@gmail.com       |
#---------------------------------------------------------------+
# History of changes:                                           |
#---------------------------------------------------------------+

export LANG=C

# source general parameters
#
source `dirname $0`/vpkshd-general-parameters

#--------------------------------------------------
# function to calculate ip, prefix, subnet, broadcast
#--------------------------------------------------

CalcNet ()
{
# calculate ip, prefix, subnet, broadcast, netmask

# bridge_ip
b_ip=`echo ${bridge_ip} | awk -F"/" '{print $1}'`
bridge_ip_prefix=`ipcalc -p ${bridge_ip} | awk -F"=" '{print $2}'`
bridge_ip_subnet=`ipcalc -n ${bridge_ip} | awk -F"=" '{print $2}'`/${bridge_ip_prefix}
bridge_ip_broadcast=`ipcalc -b ${bridge_ip} | awk -F"=" '{print $2}'`
bridge_ip_netmask=`ipcalc -m ${bridge_ip} | awk -F"=" '{print $2}'`
}


#---------------------------------------------------------------
# function to output the message about completion of  the script
#---------------------------------------------------------------

end_of_script ()
{
   cat <<END
 End time =  `date`"

 End of script `basename $0`
 The Log is available at ${LOG_FILE}
END
}


#---------------------------------------------------
# main part of the script
#---------------------------------------------------


#  check  command line parameters
#

if [ "$#" -lt 6 ]; then

    cat <<END

------------------------------------------------------------------------------------------------

  the script '`basename $0`' is designed to create ceph bridge and  fill  table '${SERVERBRIDGE}' in database '${VPKSHDDB}'

Usage: `basename $0`  <dc name>  <server name>  <server main bridge name> <ceph bridge name> <vlan id> <ip address/prefix>  [comments]
        
        <dc name>                 - data center name 
        <server name>             - dc server  name 
        <server main bridge name> - dc server main bridge name
        <ceph bridge name>        - ceph bridge name to be created
        <vlan id>                 - vlan id for ceph network
        <ip address/prefix>       - ceph bridge ip address  
        [comments]                - comments (optional)
------------------------------------------------------------------------------------------------

END

   exit 1
fi



LOG_FILE=/tmp/`basename $0`-Log-`date +"%Y-%m-%d_%H:%M:%S"`

(

   cat <<END
 Start time =  `date`

END

dbname=${VPKSHDDB}
username=${VPKSHDUSERNAME}
export RC=0  # return code

dc_name="$1"           # data center name
server_name="$2"       # dc server  name
main_bridge_name="$3"  # dc server main bridge name 
bridge_name="$4"       # ceph  bridge name
vlan_id="$5"           # ceph  network vlan id
bridge_ip="$6"         # bridge IP address/prefix

shift; shift; shift; shift; shift; shift;
comments="$@"          # comments (optional)



#
# check if bridge_ip have prefix
#
if ( ! ipcalc -p ${bridge_ip} > /dev/null 2>&1 ); then
   RC=1
   echo 
   echo "*** bridge  ip address '${bridge_ip}' has no prefix ***"
   echo 
   echo "export RC=${RC} " > /tmp/env_file
   end_of_script
   exit 1
fi

#
# calculate ip, prefix, network, broadcast, netmask
#
CalcNet




# steps to perform
#  it is needed to connect ceph ${bridge_name} to main ${main_bridge_name}
#
# ${main_bridge_name} <-port vl{vlan_id}(tag {vlan_id})=v-patch=port pat_vl${vlan_id} -> ${bridge_name}
#
#
# create in /etc/sysconfig/network-scripts/ the following files
#
# 1. ifcfg-${bridge_name}
# 2. ifcfg-vl${vlan_id}
# 3. ifcfg-pat_vl${vlan_id}

# add row to database table serverbridge 

#--------------------
# check if dc_name  exists in database
#--------------------

COMMAND="SELECT dc_name FROM ${DATACENTER} WHERE dc_name = '${dc_name}';"
var_dc_name=`psql -h ${POSTGRESERVER} -p ${POSTGRESPORT} -U ${VPKSHDUSERNAME} -t -d ${VPKSHDDB} -c "${COMMAND}"`

RC=$?

if [ $RC != 0 ]; then
  echo "Command: psql -h ${POSTGRESERVER} -p ${POSTGRESPORT} -U ${VPKSHDUSERNAME} -t -d ${VPKSHDDB} -c "${COMMAND}" "
  echo " failed with error code $RC"
  echo "export RC=${RC} " > /tmp/env_file
  end_of_script
  exit 1
fi 

if [ -z "${var_dc_name}" ]; then

  echo 
  echo "Data center  '${dc_name}' not found in database '${VPKSHDDB}'"
  echo
  RC=1
  echo "export RC=${RC} " > /tmp/env_file
  end_of_script
  exit 1
fi

#-------------------------------
# check if dcserver_name  exists in database
#-------------------------------

COMMAND="SELECT  server_name FROM  ${DCSERVER} WHERE server_name = '${server_name}' AND dc_name = '${dc_name}';"
var_dc_server=`psql -h ${POSTGRESERVER} -p ${POSTGRESPORT} -U ${VPKSHDUSERNAME} -t -d ${VPKSHDDB} -c "${COMMAND}"`

RC=$?

if [ $RC != 0 ]; then
  echo "Command: psql -h ${POSTGRESERVER} -p ${POSTGRESPORT} -U ${VPKSHDUSERNAME} -t -d ${VPKSHDDB} -c "${COMMAND}" "
  echo " failed with error code $RC"
  echo "export RC=${RC} " > /tmp/env_file
  end_of_script
  exit 1
fi 

if [ -z "${var_dc_server}" ]; then

  echo 
  echo "Server   '${server_name}' not found in database '${VPKSHDDB}'"
  echo
  RC=1
  echo "export RC=${RC} " > /tmp/env_file
  end_of_script
  exit 1
fi



SCRIPTS="/etc/sysconfig/network-scripts"

#
#  ifcfg-${bridge_name}
#

cat > /tmp/ifcfg-${bridge_name} <<EOF
DEVICE=${bridge_name}
ONBOOT=yes
BOOTPROTO=none
IPADDR=${b_ip}
NETMASK=${bridge_ip_netmask}
DEVICETYPE=ovs
TYPE=OVSBridge
EOF

sudo cp /tmp/ifcfg-${bridge_name} ${SCRIPTS}/ifcfg-${bridge_name}
rm -f /tmp/ifcfg-${bridge_name}

#
# ifcfg-vl${vlan_id}
#
cat > /tmp/ifcfg-vl${vlan_id} <<EOF
DEVICE=vl${vlan_id}
ONBOOT=yes
DEVICETYPE=ovs
TYPE=OVSPatchPort
OVS_BRIDGE=${main_bridge_name}
OVS_OPTIONS="tag=${vlan_id}"
OVS_PATCH_PEER=pat_vl${vlan_id}
EOF

sudo cp /tmp/ifcfg-vl${vlan_id} ${SCRIPTS}/ifcfg-vl${vlan_id}
rm -f /tmp/ifcfg-vl${vlan_id}

#
# ifcfg-pat_vl${vlan_id}
#
cat > /tmp/ifcfg-pat_vl${vlan_id} <<EOF
DEVICE=pat_vl${vlan_id}
ONBOOT=yes
DEVICETYPE=ovs
TYPE=OVSPatchPort
OVS_BRIDGE=${bridge_name}
OVS_PATCH_PEER=vl${vlan_id}
EOF

sudo cp /tmp/ifcfg-pat_vl${vlan_id} ${SCRIPTS}/ifcfg-pat_vl${vlan_id}
rm -f /tmp/ifcfg-pat_vl${vlan_id}

#
#  fill the table 'serverbridge' in database 'vpkshd'          
#


DATE=`date +"%Y-%m-%d %H:%M:%S" --universal`


echo "------------------------------------------------------"
echo " Adding a new bridge '${bridge_name}' to server '${server_name}' in database '${VPKSHDDB}'           "
echo "------------------------------------------------------"

COMMAND="INSERT INTO ${SERVERBRIDGE} (bridge_name, server_name, bridge_ip,  serverbridge_date, comments) \
 VALUES ('${bridge_name}', '${server_name}',  '${bridge_ip}', '${DATE}', '${comments}');"

psql -h ${POSTGRESERVER} -p ${POSTGRESPORT} -U ${VPKSHDUSERNAME} -t -d ${VPKSHDDB} -c "${COMMAND}"

RC=$?

if [ $RC != 0 ]; then
  echo "Command: psql -h ${POSTGRESERVER} -p ${POSTGRESPORT} -U ${VPKSHDUSERNAME} -t -d ${VPKSHDDB} -c "${COMMAND}" "
  echo " failed with error code $RC"
  echo "export RC=${RC} " > /tmp/env_file
  end_of_script
  exit 1
fi 

end_of_script

# save export RC  into /tmp/env_file

echo "export RC=${RC} " > /tmp/env_file
) 2>& 1 | tee ${LOG_FILE}

. /tmp/env_file
rm /tmp/env_file
#

exit  ${RC}

