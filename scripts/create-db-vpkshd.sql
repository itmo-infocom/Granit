/*
#---------------------------------------------------------------+
# PostgreSQL commands for creating database 'vpkshd'            |
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
#
#  Create database 'vpkshd'          
#
*/
\set ON_ERROR_STOP 1
CREATE DATABASE vpkshd  TEMPLATE template0 ENCODING  utf8 LC_COLLATE 'ru_RU.utf8' LC_CTYPE 'ru_RU.utf8';

