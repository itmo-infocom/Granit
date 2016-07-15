/*
#---------------------------------------------------------------+
# PostgreSQL commands for revoke default administrator          |
# for database 'vpkshd'                                         |
#                                                               |
# Creation date:  Wed Mar  9 16:06:44 MSK 2016                  |
# The host where it was developed=pnpi-itmo.pnpi.spb.ru         |
#---------------------------------------------------------------+
#                                                               |
#  Author: A. Oreshkin. email: anatoly.oreshkin@gmail.com       |
#---------------------------------------------------------------+
# History of changes:                                           |
#---------------------------------------------------------------+
*/

/*
#  Revoke default administrator granit for  database 'vpkshd'          
#
*/

\set ON_ERROR_STOP 1

REVOKE ALL PRIVILEGES ON DATABASE vpkshd FROM granit;
DROP USER granit;
