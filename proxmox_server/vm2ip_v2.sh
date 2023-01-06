#!/bin/bash
INT=vmbr0
NETWORK="192.168.100.0/24"
OUT="arp_scan.out"
arp-scan --interface=$INT $NETWORK -q -x > $OUT
for VM in `qm list 2> /dev/null | grep running | awk '{print $1}'`
do
        NAME=$(qm config $VM | awk '/name:/ {print $2}')
        MAC=$(qm config $VM | awk '/net0:/ { print tolower($2) }' | sed -r 's/virtio=(.*),.*,.*/\1/g' )
        sed -i -e "s/$MAC/$NAME/g" $OUT
done
echo " === Running VM's with IP's "
egrep -v "[a-z0-9]{2}:[a-z0-9]{2}:[a-z0-9]{2}:[a-z0-9]{2}:[a-z0-9]{2}:[a-z0-9]{2}" $OUT
rm -f $OUT
echo " === "