#!/bin/bash
#set -x
#---------------------------------------------------------------+
#                                                               |
#  Usage:                                                       |
# delete-table-db-vpkshd.sh < table name>                       |
#                                                               |
# The  script is devoted to:                                    |
#                                                               |
#  deleting a table in database  for VPKSHD                     |
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
source `dirname $0`/vpkshd-general-parameters

#  check  command line parameters
#

if [ "$#" -lt 1 ]; then

    cat <<END

------------------------------------------------------------------------------------------------

  the script '`basename $0`' is designed to delete a table in database for VPKSHD

Usage: `basename $0`  <table name> 

        <table name> - a name of a table to be deleted
------------------------------------------------------------------------------------------------

END

   exit 1
fi



#
#  Delete a table in database 'vpkshd'          
#

LOG_FILE=/tmp/`basename $0`-Log-`date +"%Y-%m-%d_%H:%M:%S"`

(

   cat <<END
 Start time =  `date`

END

dbname=${VPKSHDDB}
username=${VPKSHDUSERNAME}
export RC=0  # return code

tablename=$1    # a name of a table to create
# create sql commands file

sqlfile="/tmp/$$"

cat  >  ${sqlfile} << EOF

\set ON_ERROR_STOP 1
\d ${tablename}
DROP TABLE ${tablename};

EOF


echo "--------------------------------------"
echo " Deleting a table '${tablename}' in database ${VPKSHDDB}           "
echo "--------------------------------------"

if ( psql -f ${sqlfile} ${dbname}  ${username} ); then
  RC=$?
  echo
  echo "a table '${tablename}' in database '${dbname}' succesfully deleted"
else
  RC=$?
  echo
  echo "failed to delete a table '${tablename}' in database '${dbname}' "
  echo "return code=${RC} "
fi

   cat <<END
 End time =  `date`"

 End of script `basename $0`
 The Log is available at ${LOG_FILE}
END

rm -f ${sqlfile}

# save export RC  into /tmp/env_file

echo "export RC=${RC} " > /tmp/env_file
) 2>& 1 | tee ${LOG_FILE}

. /tmp/env_file
rm /tmp/env_file
exit  ${RC}
