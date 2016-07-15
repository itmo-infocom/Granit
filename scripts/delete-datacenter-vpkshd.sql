/*
#---------------------------------------------------------------+
# PostgreSQL commands for dropping table 'datacenter' in        |
# database 'vpkshd'                                             |
#                                                               |
# Creation date:  Tue Mar 15 12:28:11 MSK 2016                  |
# The host where it was developed=pnpi-itmo.pnpi.spb.ru         |
#---------------------------------------------------------------+
#                                                               |
#  Author: A. Oreshkin. email: anatoly.oreshkin@gmail.com       |
#---------------------------------------------------------------+
# History of changes:                                           |
#---------------------------------------------------------------+
*/

/*
#
#  Drop table 'datacenter' in database 'vpkshd'          
#
*/
\set ON_ERROR_STOP 1
\d datacenter
DROP TABLE datacenter;
