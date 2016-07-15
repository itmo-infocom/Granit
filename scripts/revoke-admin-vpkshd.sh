#!/bin/bash
#set -x
#---------------------------------------------------------------+
#                                                               |
# Usage: revoke-admin-vpkshd.sh <sql commands file>             |
#                                                               |
# The script is devoted to:                                     |
# revoking admin user for database VPKSHD                       |                                         |
#                                                               |
# Creation date:  Wed Mar  9 15:30:02 MSK 2016                  |
# The host where it was developed=pnpi-itmo.pnpi.spb.ru         |
#---------------------------------------------------------------+
#                                                               |
#  Author: A. Oreshkin. email: anatoly.oreshkin@gmail.com       |
#---------------------------------------------------------------+
# History of changes:                                           |
#---------------------------------------------------------------+

export LANG=C

# source general parameters
source `dirname $0`/vpkshd-general-parameters

#
#  check  command line parameters
#

if [ "$#" -lt 1 ]; then

    cat <<END

------------------------------------------------------------------------------------------------

  the script '`basename $0`' is designed to revoke admin user for database VPKSHD 

 Usage: `basename $0`  <sql commands file> 
       <sql commands file> - a file name containing PostgreSQL commands 
------------------------------------------------------------------------------------------------
END

   exit 1
fi


LOG_FILE=/tmp/`basename $0`-Log-`date +"%Y-%m-%d_%H:%M:%S"`

(

   cat <<END
 Start time =  `date`

END

#
#  Revoke admin user for database 'vpkshd'          
#
sql_command="revoke-admin-vpkshd.sql"
dbname=${PGDBNAME}
username=${PGUSERNAME}
export RC=0  # return code

sql_command=$1

echo "---------------------------------------------------------"
echo " Revoking admin user  for database ${VPKSHDDB}              "
echo "---------------------------------------------------------"

if ( psql -f ${sql_command} ${dbname}  ${username} ); then
  RC=$?
  echo
  echo "admin user  for database '${VPKSHDDB}' succesfully revoked"
else
  RC=$?
  echo
  echo "failed to revoke admin user  for database '${VPKSHDDB}' "
  echo "return code=${RC} "
fi

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

