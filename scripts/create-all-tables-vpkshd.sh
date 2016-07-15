#!/bin/bash
#
# create all tables in database VPKSHD
# A. Oreshkin  29.03.2016
#
#-----------------------------------------------------

./create-table-db-vpkshd.sh datacenter create-datacenter-vpkshd.sql
./create-table-db-vpkshd.sh dcserver create-dcserver-vpkshd.sql
./create-table-db-vpkshd.sh vhd create-vhd-vpkshd.sql
./create-table-db-vpkshd.sh dcswitch create-dcswitch-vpkshd.sql
./create-table-db-vpkshd.sh serverport create-serverport-vpkshd.sql
./create-table-db-vpkshd.sh serverdisk create-serverdisk-vpkshd.sql
./create-table-db-vpkshd.sh serverbridge create-serverbridge-vpkshd.sql
./create-table-db-vpkshd.sh vhdserver create-vhdserver-vpkshd.sql
./create-table-db-vpkshd.sh vhdserverdisk create-vhdserverdisk-vpkshd.sql
./create-table-db-vpkshd.sh vhdserverport create-vhdserverport-vpkshd.sql


