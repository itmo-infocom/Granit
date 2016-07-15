/*
#---------------------------------------------------------------+
# PostgreSQL commands for creating table 'dcserver' in          |
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
# 4.05.2016 change comments size                                |
# 5.05.2016 change dc_name size, cpufreq size                   |
# 10.05.2016 change timestamp with time zone -> timestamp       |
# 24.05.2016 correct ncpu_available                             |
#---------------------------------------------------------------+
*/

/*
#
#  Create table 'dcserver' in database 'vpkshd'          
#
*/
\set ON_ERROR_STOP 1
CREATE TABLE  dcserver (
 server_id serial,
 server_name varchar(64) PRIMARY KEY,
 dc_name  varchar(144) REFERENCES datacenter (dc_name),
 memory integer NOT NULL,
 ncpu integer NOT NULL,
 cpufreq numeric(8,3) NOT NULL,
 memory_available integer NOT NULL,
 ncpu_available integer NOT NULL,
 access boolean NOT NULL,
 server_date timestamp NOT NULL,
 comments varchar(1024)
);

