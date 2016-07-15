#!/bin/bash
#set -x
#---------------------------------------------------------------+
#                                                               |
#  Usage: remove-db-vpkshd.sh <sql commands file>               |
#                                                               |
# The  script is devoted to:                                    |
# removing database VPKSHD                                      |
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

#  check  command line parameters
#

if [ "$#" -lt 1 ]; then

    cat <<END

------------------------------------------------------------------------------------------------

  the script '`basename $0`' is designed to remove database for VPKSHD

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
#  Remove database 'vpkshd'          
#
sql_command="remove-db-vpkshd.sql"
dbname=${PGDBNAME}
username=${PGUSERNAME}
export RC=0  # return code

sql_command=$1

echo "--------------------------------------"
echo " Removing database '${VPKSHDDB}'           "
echo "--------------------------------------"

if ( psql -f ${sql_command} ${dbname}  ${username} ); then
  RC=$?
  echo
  echo "database '${VPKSHDDB}' succesfully removed"
else
  RC=$?
  echo
  echo "failed to remove database '${VPKSHDDB}' "
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

