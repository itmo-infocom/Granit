/*
#---------------------------------------------------------------+
# PostgreSQL commands for creating table 'vhdserverdisk' in     |
# database 'vpkshd'                                             |
# The table will be owned by the user issuing the command.      |
#                                                               |
# Creation date:  Tue Mar 29 14:44:46 MSK 2016                  |
# The host where it was developed=pnpi-itmo.pnpi.spb.ru         |
#---------------------------------------------------------------+
#                                                               |
#  Author: A. Oreshkin. email: anatoly.oreshkin@gmail.com       |
#---------------------------------------------------------------+
# History of changes:                                           |
# 8.04.2016  change vshd --> vhd                                |
# 26.04.2016 UNIQUE added                                       |
# 4.05.2016 change comments size                                |
# 10.05.2016 change timestamp with time zone -> timestamp       |
# change server_name -> vhdserver_name                          |
#---------------------------------------------------------------+
*/

/*
#
#  Create table 'vhdserverdisk' in database 'vpkshd'          
#
*/
\set ON_ERROR_STOP 1
CREATE TABLE  vhdserverdisk (
 disk_id serial,
 disk_name  varchar(126) REFERENCES serverdisk(disk_name),
 vhdserver_name varchar(64) REFERENCES vhdserver(vhdserver_name),
 disk_date timestamp  NOT NULL,
 comments varchar(1024),
 UNIQUE (disk_name,vhdserver_name)
);

