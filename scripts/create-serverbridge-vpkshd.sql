/*
#---------------------------------------------------------------+
# PostgreSQL commands for creating table 'serverbridge' in      |
# database 'vpkshd'                                             |
# The table will be owned by the user issuing the command.      |
#                                                               |
# Creation date:  Tue Mar 29 11:48:30 MSK 2016                  |
# The host where it was developed=pnpi-itmo.pnpi.spb.ru         |
#---------------------------------------------------------------+
#                                                               |
#  Author: A. Oreshkin. email: anatoly.oreshkin@gmail.com       |
#---------------------------------------------------------------+
# History of changes:                                           |
# 4.05.2016 change comments size                                |
# 10.05.2016 change timestamp with time zone -> timestamp       |
# 15.06.2016 delete NOT NULL in bridge_mac, switch_port         |
#---------------------------------------------------------------+
*/

/*
#
#  Create table 'serverbridge' in database 'vpkshd'          
#
*/
\set ON_ERROR_STOP 1
CREATE TABLE  serverbridge (
 serverbridge_id serial,
 bridge_name varchar(64) PRIMARY KEY,
 server_name  varchar(64) REFERENCES dcserver (server_name),
 bridge_mac macaddr,
 bridge_ip inet NOT NULL,
 switch_name varchar(64) REFERENCES dcswitch(switch_name),
 switch_port integer,
 serverbridge_date timestamp  NOT NULL,
 comments varchar(1024)
);
