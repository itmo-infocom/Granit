#!/bin/sh

cd /data/repo
for d in `find ../mirrors -type d`; do mkdir `echo $d | sed 's/\.\.\/mirrors//; s/^\///'`; done
for f in `find /data/mirrors -name '*.rpm'`; do ln -s $f `echo $f | sed 's/\/data\/mirrors//; s/^\///'`; done
for r in `find . -name repodata`; do createrepo --update `dirname $r`; done

mkdir /var/www/html/repos/
ln -s /data/repo/mirror.centos.org/centos/7/cloud/x86_64 /var/www/html/repos/cloud
ln -s /data/repo/mirror.speedpartner.de/epel/ /var/www/html/repos/
ln -s /data/repo/mirror.centos.org/centos/7/cloud/x86_64/openstack-liberty/ /var/www/html/repos/
ln -s /data/repo/sl7x /var/www/html/repos/
