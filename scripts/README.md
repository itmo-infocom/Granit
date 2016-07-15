# Tools for installing virtual storage cluster


check-server-accessibility.sh -- check an accessibility of servers over network to be the members of
                                 virtual storage cluster 

Files with extension .sql contain PostgreSQL commands.

- To create PostgreSQL database 'vpkshd' run the following scripts:

1. create-db-vpkshd.sh create-db-vpkshd.sql
2. create-admin-vpkshd.sh create-admin-vpkshd.sql

- To create a specific database table  run script 

create-table-db-vpkshd.sh 'table_name' create-'table_name'-vpkshd.sql

 
- To create all database tables run script

create-all-tables-vpkshd.sh


- To delete specific database table run script

delete-table-db-vpkshd.sh 'table_name'

- To delete all database tables run script

delete-all-tables-vpkshd.sh

- to delete database 'vpkshd' run scripts

1. revoke-admin-vpkshd.sh revoke-admin-vpkshd.sql
2. remove-db-vpkshd.sh remove-db-vpkshd.sql


- to create startup scripts for ceph servers (mon/osd/mds) dockers containers  run scripts:

It is supposed that database 'vpkshd' is already filled with the data.

1. create ovs bridges for public &  cluster ceph networks using a script

create-ceph-bridge-vpkshd.sh  'dc_name'  'server_name'  'server_main_bridge_name' 'ceph_bridge_name' 'vlan_id' 'ip_address/prefix'  
[comments]

This script creates bridges files in /etc/sysconfig/network-scripts directory and fills database 'vpkshd'
 
It is neccessary to restart network environment on the server to take changes in effect.

2.  create-vhdcephserver-docker-vpkshd.sh  'dc_name' 'dc_server_name'  'vhd_name' 'vhdcephserver_name'  'vhdcephserver_type' 'public_
bridge' 'cluster_bridge' 'public_ip/prefix' 'cluster_ip/prefix'  'memory' 'ncpus' [comments]

This script creates startup script for ceph server (mon/osd/mds) docker container in /usr/local/bin directory and modifies database 
'vpkshd'


The file 'vpkshd-whole-graph.jpg' shows interrelations between the tables of database 'vpkshd'

 
