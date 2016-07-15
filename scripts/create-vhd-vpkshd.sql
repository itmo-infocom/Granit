/*
#---------------------------------------------------------------+
# PostgreSQL commands for creating table 'vhd' in               |
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
# 8.04.2016 change vshd --> vhd                                 |
#                                                               |
# 4.05.2016 change {comments, vhdname} size                     |
# added vhdcreation_date                                        |
# 5.05.2016 change vhd_size size                                |
# 10.05.2016 change timestamp with time zone -> timestamp       |
#---------------------------------------------------------------+
*/

/*
#
#  Create table 'vhd' in database 'vpkshd'          
#
*/
\set ON_ERROR_STOP 1
CREATE TABLE  vhd (
 vhd_id serial,
 vhd_name  varchar(144) PRIMARY KEY,
 email varchar(64) NOT NULL,
 phones varchar(64) NOT NULL,
 nreplicas integer NOT NULL,
 vhd_size numeric(10,3) NOT NULL,
 compress varchar(64) NOT NULL,
 shifr varchar(64) NOT NULL,
 vhdcreation_date timestamp NOT NULL,
 vhd_date timestamp  NOT NULL,
 comments varchar(1024)
);

