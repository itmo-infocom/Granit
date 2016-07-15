/*
#---------------------------------------------------------------+
# PostgreSQL commands for creating table 'serverport' in          |
# database 'vpkshd'                                             |
# The table will be owned by the user issuing the command.      |
#                                                               |
# Creation date:  Thu Mar 17 17:46:23 MSK 2016                  |
# The host where it was developed=pnpi-itmo.pnpi.spb.ru         |
#---------------------------------------------------------------+
#                                                               |
#  Author: A. Oreshkin. email: anatoly.oreshkin@gmail.com       |
#---------------------------------------------------------------+
# History of changes:                                           |
# 26.04.2016                                                    |
# UNIQUE added                                                  |
# 4.05.2016 change comments size                                |
# 10.05.2016 change timestamp with time zone -> timestamp       |
#---------------------------------------------------------------+
*/

/*
#
#  Create table 'serverport' in database 'vpkshd'          
#
*/
\set ON_ERROR_STOP 1
CREATE TABLE  serverport (
 serverport_id serial,
 server_name  varchar(64)  REFERENCES dcserver (server_name),
 server_port varchar(64) NOT NULL,
 port_speed integer NOT NULL,
 port_mac macaddr NOT NULL,
 port_ip inet UNIQUE NOT NULL,
 switch_name varchar(64) REFERENCES dcswitch(switch_name),
 switch_port integer NOT NULL,
 serverport_date timestamp  NOT NULL,
 comments varchar(1024)
);

