/*
#---------------------------------------------------------------+
# PostgreSQL commands for creating table 'serverdisk' in        |
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
# 8.04.2016 added PRIMARY KEY to disk_name                      |
# 4.05.2016 change comments size                                |
# 5.05.2016 change disk_size  size                              |
# 10.05.2016 change timestamp with time zone -> timestamp       |
#---------------------------------------------------------------+
*/

/*
#
#  Create table 'serverdisk' in database 'vpkshd'          
#
*/
\set ON_ERROR_STOP 1
CREATE TABLE  serverdisk (
 disk_id serial,
 disk_name  varchar(126) PRIMARY KEY,
 server_name varchar(64) REFERENCES dcserver(server_name),
 disk_size numeric(7,2) NOT NULL,
 disk_type varchar(16) NOT NULL,
 allocated boolean NOT NULL,
 access boolean NOT NULL,
 disk_date timestamp  NOT NULL,
 comments varchar(1024)
);

