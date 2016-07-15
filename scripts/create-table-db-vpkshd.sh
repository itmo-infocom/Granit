#!/bin/bash
#set -x
#---------------------------------------------------------------+
#                                                               |
#  Usage:                                                       |
#                                                               |
# create-table-db-vpkshd.sh <table name> <sql commands file>    |
#                                                               |
# The  script is devoted to:                                    |
#                                                               |
#  creating a table in database  for VPKSHD                     |
#                                                               |
# Creation date:  Tue Mar 15 12:16:31 MSK 2016                  |
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


#  check  command line parameters
#

if [ "$#" -lt 1 ]; then

    cat <<END

------------------------------------------------------------------------------------------------

  the script '`basename $0`' is designed to create a table in database for VPKSHD

Usage: `basename $0`  <table name> <sql commands file>
        
        <table name> - a name of a table to be created
        <sql commands file> - a file name containing PostgreSQL commands
------------------------------------------------------------------------------------------------

END

   exit 1
fi



#
#  Create a table in database 'vpkshd'          
#

LOG_FILE=/tmp/`basename $0`-Log-`date +"%Y-%m-%d_%H:%M:%S"`

(

   cat <<END
 Start time =  `date`

END

sql_command="create-table-db-vpkshd.sql"
dbname=${VPKSHDDB}
username=${VPKSHDUSERNAME}
export RC=0  # return code

tablename=$1    # a name of a table to create
sql_command=$2  # a file name with sql commands

echo "------------------------------------------------------"
echo " Creating a table '${tablename}' in database '${VPKSHDDB}'           "
echo "------------------------------------------------------"

if ( psql -f ${sql_command} ${dbname}  ${username} ); then
  RC=$?
  echo
  echo "a table '${tablename}' in database '${dbname}' succesfully created"
else
  RC=$?
  echo
  echo "failed to create a table '${tablename}' in database '${dbname}' "
  echo "return code=${RC} "
fi

   cat <<END
 End time =  `date`"

 End of script `basename $0`
 The Log is available at ${LOG_FILE}
END

# save export RC  into /tmp/env_file

echo "export RC=${RC} " > /tmp/env_file
) 2>& 1 | tee ${LOG_FILE}

. /tmp/env_file
rm /tmp/env_file
exit  ${RC}
