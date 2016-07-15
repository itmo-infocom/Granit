#!/bin/bash
#
# delete all tables in database VPKSHD
# A. Oreshkin  29.03.2016
# correction 8.04.2016 vshd -> vhd
#-----------------------------------------------------

./delete-table-db-vpkshd.sh vhdserverport 
./delete-table-db-vpkshd.sh vhdserverdisk
./delete-table-db-vpkshd.sh vhdserver
./delete-table-db-vpkshd.sh serverbridge
./delete-table-db-vpkshd.sh serverdisk
./delete-table-db-vpkshd.sh serverport
./delete-table-db-vpkshd.sh dcswitch
./delete-table-db-vpkshd.sh vhd
./delete-table-db-vpkshd.sh dcserver
./delete-table-db-vpkshd.sh datacenter

