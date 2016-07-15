/*
#---------------------------------------------------------------+
# PostgreSQL commands for creating table 'dcswitch' in          |
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
# 4.05.2016 change  comments size                               |
# 5.05.2016 change dc_name size                                 |
# 10.05.2016 change timestamp with time zone -> timestamp       |
#---------------------------------------------------------------+
*/

/*
#
#  Create table 'dcswitch' in database 'vpkshd'          
#
*/
\set ON_ERROR_STOP 1
CREATE TABLE  dcswitch (
 switch_id serial,
 switch_name varchar(64) PRIMARY KEY,
 dc_name  varchar(144) REFERENCES datacenter (dc_name),
 ctrl_port integer NOT NULL,
 ctrl_port_ip inet NOT NULL,
 nports integer NOT NULL,
 model varchar(126) NOT NULL,
 access boolean NOT NULL,
 switch_date timestamp NOT NULL,
 comments varchar(1024)
);

