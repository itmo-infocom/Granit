/*
#---------------------------------------------------------------+
# PostgreSQL commands for dropping table 'dcswitch' in          |
# database 'vpkshd'                                             |
#                                                               |
# Creation date:  Fri Mar 18 16:52:43 MSK 2016                  |
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
#  Drop table 'dcswitch' in database 'vpkshd'          
#
*/
\set ON_ERROR_STOP 1
\d dcswitch
DROP TABLE dcswitch;
