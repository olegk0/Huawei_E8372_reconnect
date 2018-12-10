#!/bin/bash

read_dom () {
    local IFS=\>
    read -d \< ENTITY CONTENT
}

while read_dom; do
    case $ENTITY in
    "CurrentConnectTime")
	min=$(($CONTENT / 60))
	hr=$(($CONTENT / 3600))
	tmin=$(($hr * 60 ))
	min=$(($min - $tmin ))
	echo "ConnectTime: ${hr}:${min}"
	;;
    "CurrentUpload")
	upl=$(($CONTENT / ( 1024 * 1024 )))
	echo "Upload: $upl Mb"
	;;
    "CurrentDownload")
	dwl=$(($CONTENT / ( 1024 * 1024 )))
	echo "Download: $dwl Mb"
	;;
    esac
done < /tmp/4g_stat.txt

echo `date` " ConnectTime: ${hr}:${min} Upload: ${upl}Mb Download: ${dwl}Mb" >> /tmp/inet_stat.txt
