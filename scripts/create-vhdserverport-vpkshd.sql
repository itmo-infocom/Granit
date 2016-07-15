/*
#---------------------------------------------------------------+
# PostgreSQL commands for creating table 'vhdserverport' in     |
# database 'vpkshd'                                             |
# The table will be owned by the user issuing the command.      |
#                                                               |
# Creation date:  Tue Mar 29 14:53:00 MSK 2016                  |
# The host where it was developed=pnpi-itmo.pnpi.spb.ru         |
#---------------------------------------------------------------+
#                                                               |
#  Author: A. Oreshkin. email: anatoly.oreshkin@gmail.com       |
#---------------------------------------------------------------+
# History of changes:                                           |
#                                                               |
# 8.04.2016  change vshd --> vhd                                |
#--------------                                                 |
# 26.04.2016 UNIQUE added                                       |
#-------------                                                  |
# 4.05.2016 comments size change                                |
#-------------                                                  |
# 10.05.2016 change timestamp with time zone -> timestamp       |
# change server_name -> vhdserver_name                          |
#------------                                                   |
# 25.05.2016 delete NOT NULL from server_port varchar(64),      |
#           port_mac macaddr                                    |
#---------------------------------------------------------------+
*/

/*
#
#  Create table 'vhdserverport' in database 'vpkshd'          
#
*/
\set ON_ERROR_STOP 1
CREATE TABLE  vhdserverport (
 serverport_id serial,
 vhdserver_name  varchar(64) REFERENCES vhdserver (vhdserver_name),
 bridge_name varchar(64) REFERENCES serverbridge (bridge_name), 
 server_port varchar(64),
 port_mac macaddr,
 port_ip inet NOT NULL,
 serverport_date timestamp  NOT NULL,
 comments varchar(1024),
 UNIQUE (vhdserver_name,bridge_name,server_port)
);

