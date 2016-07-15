/*
#---------------------------------------------------------------+
# PostgreSQL commands for creating table 'vhdserver' in         |
# database 'vpkshd'                                             |
# The table will be owned by the user issuing the command.      |
#                                                               |
# Creation date:  Tue Mar 29 12:12:58 MSK 2016                  |
# The host where it was developed=pnpi-itmo.pnpi.spb.ru         |
#---------------------------------------------------------------+
#                                                               |
#  Author: A. Oreshkin. email: anatoly.oreshkin@gmail.com       |
#---------------------------------------------------------------+
# History of changes:                                           |
# 8.04.2016  change vshd --> vhd                                |
# 4.05.2016 change comments size                                |
# 5.05.2016 change vhd_name size                                |
# 10.05.2016 change timestamp with time zone -> timestamp       |
# change server_name -> vhdserver_name                          |
#---------------------------------------------------------------+
*/

/*
#
#  Create table 'vhdserver' in database 'vpkshd'          
#
*/
\set ON_ERROR_STOP 1
CREATE TABLE  vhdserver (
 server_id serial,
 vhdserver_name varchar(64) PRIMARY KEY,
 dcserver_name  varchar(64) REFERENCES dcserver (server_name),
 vhd_name varchar(144) REFERENCES vhd (vhd_name),
 memory integer NOT NULL,
 ncpu integer NOT NULL,
 server_type varchar(16) NOT NULL,
 access boolean NOT NULL,
 server_date timestamp  NOT NULL,
 comments varchar(1024)
);

