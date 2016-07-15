#!/bin/bash
#set -x
#---------------------------------------------------------------+
#                                                               |
#  Usage:                                                       |
#                                                               |
# create-vhdcephserver-docker-vpkshd.sh <dc name> <dc server>   |
#      <vhd>  <vhdcephserver name> <server type> <public bridge>|
#      <cluster bridge> <public ip/prefix> <cluster ip/prefix>  |
#      <memory> <ncpus> [comments]                              |
#                                                               |
# The  script is devoted to:                                    |
#                                                               |
#  creating vhd ceph server                                     |
#                                                               |
# Creation date:  Tue May 17 16:35:26 MSK 2016                  |
# The host where it was developed=pnpi-itmo.pnpi.spb.ru         |
#---------------------------------------------------------------+
#                                                               |
#  Author: A. Oreshkin. email: anatoly.oreshkin@gmail.com       |
#---------------------------------------------------------------+
# History of changes:                                           |
# 12.07.2016                            |
# delete <number of disks> & <disk serial number>               |
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
# calculate ip, prefix, subnet, broadcast

# public ip
p_ip=`echo ${public_ip} | awk -F"/" '{print $1}'`
public_prefix=`ipcalc -p ${public_ip} | awk -F"=" '{print $2}'`
public_subnet=`ipcalc -n ${public_ip} | awk -F"=" '{print $2}'`/${public_prefix}
public_broadcast=`ipcalc -b ${public_ip} | awk -F"=" '{print $2}'`

# cluster ip
c_ip=`echo ${cluster_ip} | awk -F"/" '{print $1}'`
cluster_prefix=`ipcalc -p ${cluster_ip} | awk -F"=" '{print $2}'`
cluster_subnet=`ipcalc -n ${cluster_ip} | awk -F"=" '{print $2}'`/${cluster_prefix}
cluster_broadcast=`ipcalc -b ${cluster_ip} | awk -F"=" '{print $2}'`
}

#------------------------------------------------------------------------
#  function
# to check if memory available & NCPUs available is enough for vhd server
#------------------------------------------------------------------------

CheckMemNCPU ()
{

#----
# get memory_available & ncpu_available in  'dcserver' table
#---

COMMAND="SELECT memory_available,  ncpu_available  FROM ${DCSERVER} WHERE dc_name = '${dc_name}' AND server_name = '${dcserver_name}';"

var_result=`psql -h ${POSTGRESERVER} -p ${POSTGRESPORT} -U ${VPKSHDUSERNAME} -t -d ${VPKSHDDB} -c "${COMMAND}"`

RC=$?

if [ $RC != 0 ]; then
  echo "Command: psql -h ${POSTGRESERVER} -p ${POSTGRESPORT} -U ${VPKSHDUSERNAME} -t -d ${VPKSHDDB} -c "${COMMAND}" "
  echo " failed with error code $RC"
  echo "export RC=${RC} " > /tmp/env_file
  end_of_script
  exit 1
fi 

memory_available=`echo ${var_result} | awk -F "|" '{print $1}'`
ncpu_available=`echo ${var_result} | awk -F "|" '{print $2}'`

#
#  check if memory and ncpu are sufficient for vhd ceph server
# 

memory_available=`expr ${memory_available} - ${memory}`
ncpu_available=`expr ${ncpu_available} - ${ncpus}`



if [ "${memory_available}" -lt "0" ]; then
  echo
  echo "*** available memory '${memory_available}' for vhd server less then required memory ${memory}. Exiting ***"
  echo
  RC=1
  echo "export RC=${RC} " > /tmp/env_file 
  end_of_script
  exit 1
fi

if [ "${ncpu_available}" -lt "0" ]; then
  echo
  echo "*** available number of CPUs  '${ncpu_available}' for vhd server less then required  ${ncpus}. Exiting ***"
  echo 
  RC=1
  echo "export RC=${RC} " > /tmp/env_file
  end_of_script
  exit 1
fi

}

#---------------------------------------------------
# function to add new vhdserver  to 'vhdserver' table
#---------------------------------------------------
AddVhdServer ()
{

#
# insert to vhdserver table
#

echo "---------------------------------------------------------------------------------------"
echo " Adding a new VHD server '${vhdcephserver_name}'  to  database '${VPKSHDDB}'           "
echo "---------------------------------------------------------------------------------------"


COMMAND="INSERT INTO ${VHDSERVER} (vhdserver_name, dcserver_name, vhd_name, memory, ncpu, server_type, access, server_date, comments) \
  VALUES ('${vhdcephserver_name}', '${dcserver_name}', '${vhd_name}', '${memory}', '${ncpus}', '${vhdcephserver_type}', '${access}', '${DATE}', '${comments}');"

psql -h ${POSTGRESERVER} -p ${POSTGRESPORT} -U ${VPKSHDUSERNAME} -t -d ${VPKSHDDB} -c "${COMMAND}"

RC=$?

if [ $RC != 0 ]; then
  echo "Command: psql -h ${POSTGRESERVER} -p ${POSTGRESPORT} -U ${VPKSHDUSERNAME} -t -d ${VPKSHDDB} -c "${COMMAND}" "
  echo " failed with error code $RC"
  echo "export RC=${RC} " > /tmp/env_file
  end_of_script
  exit 1
fi 

}


#--------------------------------------------------------
# function to add vhdserver port to table 'vhdserverport'
#--------------------------------------------------------

AddVhdPort ()
{

#
# add new vhdserver port to 'vhdserverport' table
#

echo "---------------------------------------------------------------------------------------"
echo " Inserting port '${server_port}' in table '${VHDSERVERPORT}' for new  VHD server '${vhdcephserver_name}'  to  database '${VPKSHDDB}'           "
echo "---------------------------------------------------------------------------------------"


COMMAND="INSERT INTO ${VHDSERVERPORT} (vhdserver_name, bridge_name, server_port, port_ip, serverport_date, comments) \
  VALUES ('${vhdcephserver_name}',  '${bridge}', '${server_port}', '${server_ip}',  '${DATE}', '${comments}');"

psql -h ${POSTGRESERVER} -p ${POSTGRESPORT} -U ${VPKSHDUSERNAME} -t -d ${VPKSHDDB} -c "${COMMAND}"

RC=$?

if [ $RC != 0 ]; then
  echo "Command: psql -h ${POSTGRESERVER} -p ${POSTGRESPORT} -U ${VPKSHDUSERNAME} -t -d ${VPKSHDDB} -c "${COMMAND}" "
  echo " failed with error code $RC"
  echo "export RC=${RC} " > /tmp/env_file
  end_of_script
  exit 1
fi 

}

#---------------------------------------------------------
# function to add vhdserver disk  to table 'vhdserverdisk'
#---------------------------------------------------------

AddVhdDisk ()
{

echo "---------------------------------------------------------------------------------------------------------------------------"
echo " Inserting disk '${vhddisk}' in table '${VHDSERVERDISK}' for new  VHD server '${vhdcephserver_name}'  to  database '${VPKSHDDB}'        "
echo "---------------------------------------------------------------------------------------------------------------------------"


COMMAND="INSERT INTO ${VHDSERVERDISK} (disk_name, vhdserver_name, disk_date, comments) \
  VALUES ('${vhddisk}', '${vhdcephserver_name}', '${DATE}', '${comments}');"

psql -h ${POSTGRESERVER} -p ${POSTGRESPORT} -U ${VPKSHDUSERNAME} -t -d ${VPKSHDDB} -c "${COMMAND}"

RC=$?

if [ $RC != 0 ]; then
  echo "Command: psql -h ${POSTGRESERVER} -p ${POSTGRESPORT} -U ${VPKSHDUSERNAME} -t -d ${VPKSHDDB} -c "${COMMAND}" "
  echo " failed with error code $RC"
  echo "export RC=${RC} " > /tmp/env_file
  end_of_script
  exit 1
fi 

}

#-------------------------------------------
# function to update 'serverdisk' table
#-------------------------------------------
UpdServerDisk ()
{

#
# update 'serverdisk' table
#

echo "---------------------------------------------------------------------------------------"
echo " Updating '${SERVERDISK}' table  for server '${dcserver_name}'  in  database '${VPKSHDDB}' "
echo "---------------------------------------------------------------------------------------"

COMMAND="UPDATE ${SERVERDISK}  SET allocated = 't', disk_date = '${DATE}' FROM ${DCSERVER} WHERE ${DCSERVER}.dc_name = '${dc_name}' AND ${SERVERDISK}.server_name = '${dcserver_name}' \
AND ${SERVERDISK}.server_name = ${DCSERVER}.server_name AND ${SERVERDISK}.disk_name = '${vhddisk}';"

psql -h ${POSTGRESERVER} -p ${POSTGRESPORT} -U ${VPKSHDUSERNAME} -t -d ${VPKSHDDB} -c "${COMMAND}"

RC=$?
  
if [ $RC != 0 ]; then
  echo "Command: psql -h ${POSTGRESERVER} -p ${POSTGRESPORT} -U ${VPKSHDUSERNAME} -t -d ${VPKSHDDB} -c "${COMMAND}" "
  echo " failed with error code $RC"
  echo "export RC=${RC} " > /tmp/env_file
  end_of_script
  exit 1
fi
}

#-------------------------------------------
# function to update 'dcserver' table
#-------------------------------------------
UpdDcServer ()
{

#
# update 'dcserver' table
#

echo "---------------------------------------------------------------------------------------"
echo " Updating '${DCSERVER}' table  for server '${dcserver_name}'  in  database '${VPKSHDDB}' "
echo "---------------------------------------------------------------------------------------"

COMMAND="UPDATE ${DCSERVER} SET memory_available = '${memory_available}',  ncpu_available = '${ncpu_available}', server_date = '${DATE}' WHERE dc_name = '${dc_name}' AND \
server_name = '${dcserver_name}';"

psql -h ${POSTGRESERVER} -p ${POSTGRESPORT} -U ${VPKSHDUSERNAME} -t -d ${VPKSHDDB} -c "${COMMAND}"

RC=$?
  
if [ $RC != 0 ]; then
  echo "Command: psql -h ${POSTGRESERVER} -p ${POSTGRESPORT} -U ${VPKSHDUSERNAME} -t -d ${VPKSHDDB} -c "${COMMAND}" "
  echo " failed with error code $RC"
  echo "export RC=${RC} " > /tmp/env_file
  end_of_script
  exit 1
fi
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
#
# main part of the script
#
#---------------------------------------------------



#---------------------------------------------------------------------

#  check  command line parameters
#

if [ "$#" -lt 11 ]; then

    cat <<END

------------------------------------------------------------------------------------------------

  the script '`basename $0`' is designed to create vhd ceph server in docker container 

Usage: `basename $0`  <dc name> <dc server name>  <vhd name> <vhdcephserver name>  <vhdcephserver type> <public bridge> <cluster bridge> <public ip/prefix> <cluster ip/prefix> \
    <memory> <ncpus> [comments]

        <dc name>            - data center name
        <dc server name>     - data center server name
        <vhd name>           - vhd name
        <vhdcephserver name> - vhd ceph server  name
        <vhdcephserver type> - vhd ceph server type (mon/osd/mds)
        <public bridge>      - ceph public network bridge name 
        <cluster bridge>     - ceph cluster network bridge name
        <public ip/prefix>   - ceph public vhd server ip address/prefix
        <cluster ip/prefix>  - ceph cluster vhd server ip address/prefix (0.0.0.0/0 for mds server)
        <memory>             - operating memory size for vhd server
        <ncpus>              - number of CPUs for vhd server
        [comments]           - comments (optional)
------------------------------------------------------------------------------------------------

END

   exit 1
fi



#----------------------------------------------------
#  create vhd ceph server and add it to database
#  main part          
#----------------------------------------------------

LOG_FILE=/tmp/`basename $0`-Log-`date +"%Y-%m-%d_%H:%M:%S"`

(

   cat <<END
 Start time =  `date`

END


dbname=${VPKSHDDB}
username=${VPKSHDUSERNAME}
export RC=0  # return code

dc_name=$1               # data center name
dcserver_name=$2         # dc server name
vhd_name=$3              # vhd name
vhdcephserver_name=$4    # vhd ceph server name
vhdcephserver_type=$5    # vhd ceph server type (mon/osd/mds)
public_bridge=$6         # ceph public network bridge name
cluster_bridge=$7        # ceph cluster network bridge name
public_ip=$8             # vhd ceph server public ip address/prefix
cluster_ip=$9            # vhd ceph server cluster ip address/prefix
memory=${10}             # memory size for vhd ceph server
ncpus=${11}              # a number of CPUs for vhd ceph server

shift; shift; shift; shift; shift; shift; shift; shift; shift; shift; shift;
comments="$@"          # comments (optional)
number_of_disks=1      # the number of disks for vhdcephserver

scriptdir="/usr/local/bin" # where to write startup script for vhd ceph server 

#
# check if public_ip & cluster_ip have prefix
#
if ( ! ipcalc -p ${public_ip} > /dev/null 2>&1 ); then
   RC=1
   echo 
   echo "*** vhd server public ip address has no prefix ***"
   echo 
   echo "export RC=${RC} " > /tmp/env_file
   end_of_script
   exit 1
fi

if ( ! ipcalc  -p ${cluster_ip} > /dev/null 2>&1 ); then
   RC=1
   echo
   echo "*** vhd server cluster ip address has no prefix ***"
   echo
   echo "export RC=${RC} " > /tmp/env_file
   end_of_script
   exit 1
fi
 


#
#  check for vhd server type (mon/osd/mds)
#

 case "${vhdcephserver_type}" in

  mon) 
        ;;
  osd)
        ;;
  mds)  
        ;;
  *)    echo
        echo "*** Unknown vhd server type. Exiting ***"
        echo
        RC=1
        echo "export RC=${RC} " > /tmp/env_file
        exit 1
        ;;
  
 esac


#
# steps to perform the task
#

# 1. check if dc_name & dcserver_name & vhd_name  exist in database
# 2. check if public bridge & cluster bridge exist in database
# 3. check if sufficient memory & NCPUs on dcserver for vhdserver 
# 4. check if  sufficient disks for vhdserver
# 5. add rows to database tables: vhdserver, vhdserverport, vhdserverdisk
# 6. correct database tables: dcserver, serverdisk  
# 7. create startup script for vhd ceph server

DATE=`date +"%Y-%m-%d %H:%M:%S" --universal`
	
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

COMMAND="SELECT  server_name FROM  ${DCSERVER} WHERE server_name = '${dcserver_name}' AND dc_name = '${dc_name}';"
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
  echo "Server   '${dcserver_name}' not found in database '${VPKSHDDB}'"
  echo
  RC=1
  echo "export RC=${RC} " > /tmp/env_file
  end_of_script
  exit 1
fi


#-------------------------------
# check if vhd_name  exists in database
#-------------------------------

COMMAND="SELECT  vhd_name FROM  ${VHD} WHERE vhd_name = '${vhd_name}';"
var_vhd_name=`psql -h ${POSTGRESERVER} -p ${POSTGRESPORT} -U ${VPKSHDUSERNAME} -t -d ${VPKSHDDB} -c "${COMMAND}"`

RC=$?

if [ $RC != 0 ]; then
  echo "Command: psql -h ${POSTGRESERVER} -p ${POSTGRESPORT} -U ${VPKSHDUSERNAME} -t -d ${VPKSHDDB} -c "${COMMAND}" "
  echo " failed with error code $RC"
  echo "export RC=${RC} " > /tmp/env_file
  end_of_script
  exit 1
fi 

if [ -z "${var_vhd_name}" ]; then

  echo 
  echo "VHD   '${vhd_name}' not found in database '${VPKSHDDB}'"
  echo
  RC=1
  echo "export RC=${RC} " > /tmp/env_file
  end_of_script
  exit 1
fi


#-------------------------------
# check if public bridge  exist in database
#-------------------------------

COMMAND="SELECT  bridge_name    FROM ${SERVERBRIDGE}  WHERE server_name = '${dcserver_name}' AND bridge_name = '${public_bridge}';"
var_bridge_name=`psql -h ${POSTGRESERVER} -p ${POSTGRESPORT} -U ${VPKSHDUSERNAME} -t -d ${VPKSHDDB} -c "${COMMAND}"`

RC=$?

if [ $RC != 0 ]; then
  echo "Command: psql -h ${POSTGRESERVER} -p ${POSTGRESPORT} -U ${VPKSHDUSERNAME} -t -d ${VPKSHDDB} -c "${COMMAND}" "
  echo " failed with error code $RC"
  echo "export RC=${RC} " > /tmp/env_file
  end_of_script
  exit 1
fi 

if [ -z "${var_bridge_name}" ]; then

  echo 
  echo "ceph public bridge  '${public_bridge}' not found in database '${VPKSHDDB}'"
  echo
  RC=1
  echo "export RC=${RC} " > /tmp/env_file
  end_of_script
  exit 1
fi

#-------------------------------
# check if cluster bridge  exist in database
#-------------------------------

COMMAND="SELECT  bridge_name    FROM ${SERVERBRIDGE}  WHERE server_name = '${dcserver_name}' AND bridge_name = '${cluster_bridge}';"
var_bridge_name=`psql -h ${POSTGRESERVER} -p ${POSTGRESPORT} -U ${VPKSHDUSERNAME} -t -d ${VPKSHDDB} -c "${COMMAND}"`

RC=$?

if [ $RC != 0 ]; then
  echo "Command: psql -h ${POSTGRESERVER} -p ${POSTGRESPORT} -U ${VPKSHDUSERNAME} -t -d ${VPKSHDDB} -c "${COMMAND}" "
  echo " failed with error code $RC"
  echo "export RC=${RC} " > /tmp/env_file
  end_of_script
  exit 1
fi 

if [ -z "${var_bridge_name}" ]; then

  echo 
  echo "ceph cluster bridge  '${cluster_bridge}' not found in database '${VPKSHDDB}'"
  echo
  RC=1
  echo "export RC=${RC} " > /tmp/env_file
  end_of_script
  exit 1
fi



#------------------------------------------------
#   create 'mon' vhd ceph server
#------------------------------------------------
 
if [ "${vhdcephserver_type}" = "mon" ]; then

access=true
DATE=`date +"%Y-%m-%d %H:%M:%S" --universal`


#
# calculate ip, prefix, network, broadcast
#
CalcNet

#
# check if memory & NCPUs are available for vhd server
#
CheckMemNCPU 


#-------------------------------
# update database
#-------------------------------


#
# add new vhdserver to 'vhdserver' table
#
AddVhdServer

#
# add new vhdserver port to 'vhdserverport' table
#

public_port=eth0
bridge=${public_bridge}
server_port=${public_port}
server_ip=${public_ip}

AddVhdPort


# 
# update 'dcserver' table
#
UpdDcServer

#------
# create startup script for 'mon' server
#------

echo "---------------------------------------------------------------------"
echo "Creating startup script ${scriptdir}/startup-${vhdcephserver_name}.sh"
echo "---------------------------------------------------------------------"


cat > /tmp/startup-${vhdcephserver_name}.sh << EOF
#-----------------------------------------------------------
#!/bin/sh
# startup script for 'mon' ceph server ${vhdcephserver_name}
#  created `date` on `hostname`
#-----------------------------------------------------------
#
sudo docker run -d --net=host \
--name ${vhdcephserver_name} \
-v /etc/ceph-${vhd_name}:/etc/ceph \
-v /var/lib/ceph-${vhd_name}/:/var/lib/ceph/ \
-e MON_IP=${p_ip} \
-e MON_NAME="${vhdcephserver_name}" \
-e CEPH_PUBLIC_NETWORK=${public_subnet} \
-e CEPH_CLUSTER_NETWORK=${cluster_subnet} \
ceph/daemon mon
EOF


sudo cp /tmp/startup-${vhdcephserver_name}.sh ${scriptdir}/startup-${vhdcephserver_name}.sh
sudo  chmod +x ${scriptdir}/startup-${vhdcephserver_name}.sh
rm -f /tmp/startup-${vhdcephserver_name}.sh


fi  # end 'mon' server

#------------------------------------------------
#   create 'osd' vhd ceph server
#------------------------------------------------
 
if [ "${vhdcephserver_type}" = "osd" ]; then

access=true
DATE=`date +"%Y-%m-%d %H:%M:%S" --universal`


#
# calculate ip, prefix, network, broadcast
#
CalcNet

#
# check if memory & NCPUs are sufficient for vhd server
#
CheckMemNCPU 



#
#  check if required number of disks is available
#

#
# get the number of disks available from database
#

COMMAND="SELECT count(*) FROM ${DCSERVER}, ${SERVERDISK} WHERE ${DCSERVER}.dc_name = '${dc_name}' AND ${SERVERDISK}.server_name = '${dcserver_name}' \
AND ${SERVERDISK}.server_name = ${DCSERVER}.server_name AND allocated = 'f' AND disk_type = 'hdd';"

var_number=`psql -h ${POSTGRESERVER} -p ${POSTGRESPORT} -U ${VPKSHDUSERNAME} -t -d ${VPKSHDDB} -c "${COMMAND}"`

RC=$?

if [ $RC != 0 ]; then
  echo "Command: psql -h ${POSTGRESERVER} -p ${POSTGRESPORT} -U ${VPKSHDUSERNAME} -t -d ${VPKSHDDB} -c "${COMMAND}" "
  echo " failed with error code $RC"
  echo "export RC=${RC} " > /tmp/env_file
  end_of_script
  exit 1
fi 

if [ "${var_number}" -lt "${number_of_disks}" ]; then
  echo
  echo "*** The number of avaiable disks '${var_number}' <  requested number of disks '${number_of_disks}' ***"
  echo
  RC=1
  echo "export RC=${RC} " > /tmp/env_file
  end_of_script
  exit 1
fi

#
# get the list of disks from database
# 
COMMAND="SELECT string_agg(disk_name, ',') FROM ${DCSERVER}, ${SERVERDISK} WHERE ${DCSERVER}.dc_name = '${dc_name}' AND ${SERVERDISK}.server_name = '${dcserver_name}' \
AND ${SERVERDISK}.server_name = ${DCSERVER}.server_name AND allocated = 'f' AND disk_type = 'hdd';"

disk_list=`psql -h ${POSTGRESERVER} -p ${POSTGRESPORT} -U ${VPKSHDUSERNAME} -t -d ${VPKSHDDB} -c "${COMMAND}"`

RC=$?

if [ $RC != 0 ]; then
  echo "Command: psql -h ${POSTGRESERVER} -p ${POSTGRESPORT} -U ${VPKSHDUSERNAME} -t -d ${VPKSHDDB} -c "${COMMAND}" "
  echo " failed with error code $RC"
  echo "export RC=${RC} " > /tmp/env_file
  end_of_script
  exit 1
fi 

#
# create OSD_DEVICE="/dev/sdx" for startup script 
#

OSD_DEVICE=""

N=${number_of_disks}      # number of disks required
for (( i=1; i<=${N}; i++)); do
  OSD_DEVICE="${OSD_DEVICE}`echo -n ${disk_list} | awk -F "," '{print $'$i'}'`"  
done

OSD_DEVICE="/dev/${OSD_DEVICE}"



#-------------------------------
# update database
#-------------------------------

#
# add new vhdserver to 'vhdserver' table
#
AddVhdServer

#
# add new vhdserver ports to 'vhdserverport' table
#

# public port

public_port=eth0
bridge=${public_bridge}
server_port=${public_port}
server_ip=${public_ip}

AddVhdPort

# cluster port

cluster_port=eth1
bridge=${cluster_bridge}
server_port=${cluster_port}
server_ip=${cluster_ip}

AddVhdPort

#
# add new vhdserver disks to 'vhdserdisk' table
#

N=${number_of_disks}      # number of disks required

for (( i=1; i<=${N}; i++)); do
  vhddisk=`echo -n ${disk_list} | awk -F "," '{print $'$i'}'`
  AddVhdDisk # add disk to table 'vhdserverdisk;
done

#
# update 'serverdisk' table
#

N=${number_of_disks}      # number of disks required

for (( i=1; i<=${N}; i++)); do
  vhddisk=`echo -n ${disk_list} | awk -F "," '{print $'$i'}'`
  UpdServerDisk # update table 'serverdisk' to mark disk as allocated
done



#
# update 'dcserver' table
#
UpdDcServer


#------
# create startup script for 'osd' server
#------

echo "---------------------------------------------------------------------"
echo "Creating startup script ${scriptdir}/startup-${vhdcephserver_name}.sh"
echo "---------------------------------------------------------------------"

cat > /tmp/startup-${vhdcephserver_name}.sh << EOF
#-----------------------------------------------------------
#!/bin/sh
# startup script for 'osd' ceph server ${vhdcephserver_name}
#  created `date` on `hostname`
#-----------------------------------------------------------
#
sudo docker run -d --net=none \
--name="${vhdcephserver_name}" \
--privileged=true \
-v /etc/ceph-${vhd_name}:/etc/ceph \
-v /var/lib/ceph-${vhd_name}/:/var/lib/ceph/ \
-v /var/lib/ceph-${vhd_name}/${vhdcephserver_name}:/var/lib/ceph/osd \
-v /dev/:/dev/ \
-e HOSTNAME="${vhdcephserver_name}" \
-e OSD_DEVICE="${OSD_DEVICE}" \
-e OSD_FORCE_ZAP=1 \
ceph/daemon osd

sudo ovs-docker add-port ${public_bridge} ${public_port} ${vhdcephserver_name} --ipaddress=${public_ip}
sudo ovs-docker add-port ${cluster_bridge} ${cluster_port} ${vhdcephserver_name} --ipaddress=${cluster_ip}
docker exec ${vhdcephserver_name} ifconfig ${public_port} inet ${public_ip} broadcast ${public_broadcast}
docker exec ${vhdcephserver_name} ifconfig ${cluster_port} inet ${cluster_ip} broadcast ${cluster_broadcast}
EOF

sudo cp /tmp/startup-${vhdcephserver_name}.sh ${scriptdir}/startup-${vhdcephserver_name}.sh
sudo  chmod +x ${scriptdir}/startup-${vhdcephserver_name}.sh
rm -f /tmp/startup-${vhdcephserver_name}.sh


fi # end of 'osd' server



#------------------------------------------------
#   create 'mds' vhd ceph server
#------------------------------------------------
 
if [ "${vhdcephserver_type}" = "mds" ]; then

access=true
DATE=`date +"%Y-%m-%d %H:%M:%S" --universal`
 
#
# calculate ip, prefix, network, broadcast
#
CalcNet

#
# check if memory & NCPUs are available for vhd server
#
CheckMemNCPU

#-------------------------------
# update database
#-------------------------------

#
# check if memory & NCPUs are available for vhd server
#
CheckMemNCPU 

#
# add new vhdserver to 'vhdserver' table
#
AddVhdServer

# 
# update 'dcserver' table
#
UpdDcServer


#------
# create startup script for mds server
#------

echo "---------------------------------------------------------------------"
echo "Creating startup script ${scriptdir}/startup-${vhdcephserver_name}.sh"
echo "---------------------------------------------------------------------"

cat > /tmp/startup-${vhdcephserver_name}.sh << EOF
#-----------------------------------------------------------
#!/bin/sh
# startup script for 'mds' ceph server ${vhdcephserver_name}
#  created `date` on `hostname`
#-----------------------------------------------------------
#
sudo docker run -d --net=host \
--name ${vhdcephserver_name} \
-v /etc/ceph-${vhd_name}:/etc/ceph \
-v /var/lib/ceph-${vhd_name}/:/var/lib/ceph/ \
-e MDS_NAME="${vhdcephserver_name}" \
-e CEPHFS_CREATE=1 \
ceph/daemon mds
EOF

sudo cp /tmp/startup-${vhdcephserver_name}.sh ${scriptdir}/startup-${vhdcephserver_name}.sh
sudo  chmod +x ${scriptdir}/startup-${vhdcephserver_name}.sh
rm -f /tmp/startup-${vhdcephserver_name}.sh


fi  # end 'mds' server

#---------------------------------------------

end_of_script

# save export RC  into /tmp/env_file

echo "export RC=${RC} " > /tmp/env_file
) 2>& 1 | tee ${LOG_FILE}

. /tmp/env_file
rm /tmp/env_file
#

exit  ${RC}
