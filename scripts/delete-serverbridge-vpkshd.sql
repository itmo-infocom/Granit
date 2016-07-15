/*
#---------------------------------------------------------------+
# PostgreSQL commands for dropping table 'serverbridge' in      |
# database 'vpkshd'                                             |
#                                                               |
# Creation date:  Tue Mar 29 16:08:29 MSK 2016                  |
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
#  Drop table 'serverbridge' in database 'vpkshd'          
#
*/
\set ON_ERROR_STOP 1
\d serverbridge
DROP TABLE serverbridge;
