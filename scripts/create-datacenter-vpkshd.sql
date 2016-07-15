/*
#---------------------------------------------------------------+
# PostgreSQL commands for creating table 'datacenter' in        |
# database 'vpkshd'                                             |
# The table will be owned by the user issuing the command.      |
#                                                               |
# Creation date:  Mon Mar 14 11:52:35 MSK 2016                  |
# The host where it was developed=pnpi-itmo.pnpi.spb.ru         |
#---------------------------------------------------------------+
#                                                               |
#  Author: A. Oreshkin. email: anatoly.oreshkin@gmail.com       |
#---------------------------------------------------------------+
# History of changes:                                           |
# 4.05.2016 change {comments,dc_name} size                      |
# 5.05.2016 change dc_name size                                 |
# 10.05.2016 change timestamp with time zone -> timestamp       |
#---------------------------------------------------------------+
*/

/*
#
#  Create table datacenter in database 'vpkshd'          
#
*/
\set ON_ERROR_STOP 1
CREATE TABLE  datacenter (
 dc_id serial,
 dc_name varchar(144) primary key,
 dc_date timestamp NOT NULL,
 dc_email varchar(64) NOT NULL,
 dc_phones varchar(64) NOT NULL,
 dc_address varchar(126) NOT NULL,
 dc_comments varchar(1024)
);

/*
CREATE INDEX  datacenter_id ON datacenter (dc_id);
*/
