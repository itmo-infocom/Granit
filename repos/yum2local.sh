#!/bin/sh

test -d /etc/yum.repos.d.orig || cp -ap /etc/yum.repos.d /etc/yum.repos.d.orig
cd /etc/yum.repos.d

for r in ../yum.repos.d.orig/sl*.repo
do
	out=`basename $r`
	echo $out
	sed 's?baseurl=http://ftp.scientificlinux.org/linux/scientific/$slreleasever/$basearch?baseurl=http://c01/repos/sl7x?; s?baseurl=http://ftp.scientificlinux.org/linux/scientific/7x/?baseurl=http://c01/repos/sl7x/?; s/^\( \+\)\([hf]\)/#\1\2/' < $r > $out
done

test -f epel.repo && sed 's?#baseurl=http://download.fedoraproject.org/pub/?baseurl=http://c01/repos/?; s/^mirrorlist/#mirrorlist/' < ../yum.repos.d.orig/epel.repo > epel.repo 
test -f rdo-release.repo && sed 's?baseurl=http://mirror.centos.org/centos/7/cloud/$basearch/?baseurl=http://c01/repos/?' < ../yum.repos.d.orig/rdo-release.repo  > rdo-release.repo

yum clean all
