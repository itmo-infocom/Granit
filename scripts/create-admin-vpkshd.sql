/*
#---------------------------------------------------------------+
# PostgreSQL commands for creating default administrator        |
# for database 'vpkshd'                                         |
#                                                               |
# Creation date:  Tue Mar  1 14:56:57 MSK 2016                  |
# The host where it was developed=pnpi-itmo.pnpi.spb.ru         |
#---------------------------------------------------------------+
#                                                               |
#  Author: A. Oreshkin. email: anatoly.oreshkin@gmail.com       |
#---------------------------------------------------------------+
# History of changes:                                           |
#---------------------------------------------------------------+
*/

/*
#  Create default administrator granit for  database 'vpkshd'          
#
*/
\set ON_ERROR_STOP 1
CREATE USER granit with PASSWORD 'GranPass01' LOGIN;

/*
# granit  can proccess  any table in 'vpkshd'
*/


GRANT ALL PRIVILEGES ON DATABASE vpkshd TO granit;

