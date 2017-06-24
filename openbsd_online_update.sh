#!/bin/sh

VERSION=61
TARBALL_DIR=/root/upgrade

set -ex

case "$1" in
  verify)
    cd "$TARBALL_DIR"
    signify -C -p /etc/signify/openbsd-${VERSION}-base.pub -x SHA256.sig \
      [!S][!H][!A]*
    sha256 -C SHA256 [!S][!H][!A]*
    cd -
    ;;
  pre)
    cp -p /bsd /bsd.prev
    cp -p /bsd.rd /bsd.rd.prev
    cp -p /sbin/reboot /sbin/oreboot
    ;;
  upgrade)
    cd "$TARBALL_DIR"
    cp -p bsd.rd /bsd.rd.new
    mv /bsd.rd.new /bsd.rd
    cp -p bsd /bsd.sp.new 
    mv /bsd.sp.new /bsd.sp
    cp -p bsd.mp /bsd.new
    mv /bsd.new /bsd
    tar -C / -xvzphf xfont${VERSION}.tgz
    tar -C / -xvzphf xshare${VERSION}.tgz 
    tar -C / -xvzphf xbase${VERSION}.tgz 
    tar -C / -xvzphf comp${VERSION}.tgz 
    tar -C / -xvzphf man${VERSION}.tgz 
    tar -C / -xvzphf base${VERSION}.tgz 
    cd -
    ;;
  reboot)
    /sbin/oreboot 
    ;;
  post)
    cd /dev/
    ./MAKEDEV all
    cd -
    installboot -v sd0
    sysmerge 
    fw_update -v
    pkg_add -u
    ;;
  finish)
    uname -a
    pfctl -sr
    rm /sbin/oreboot 
    ;;
  *)
    echo "unknown command. available: verify, pre, upgrade, reboot, post, finish"
    exit 1
    ;;
esac
