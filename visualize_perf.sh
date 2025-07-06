#!/bin/bash

if [ $# -ne 1 ]
then
    >&2 printf "Usage $0 <perf_filepath>\n\nExample:\n\t$0 ./perf_record/quiche/curl_http3_perf.data\n\n"
    exit 1
fi


which hotspot > /dev/null

if [ $? -ne 0 ]
then
    if [ ! -f "./hotspot.AppImage" ]
    then
        echo "Downloading hotspot..."
        curl -L https://github.com/KDAB/hotspot/releases/download/v1.5.1/hotspot-v1.5.1-x86_64.AppImage --output hotspot.AppImage
        chmod +x hotspot.AppImage
    fi
    HOTSPOT_COMMAND="./hotspot.AppImage"
else
    HOTSPOT_COMMAND="hotspot"
fi

if [[ $1 == *"quiceh"* ]]
then
    LIB_QUIC="quiceh"
else
    LIB_QUIC="quiche"
fi

CONTAINER_ROOT=$(docker inspect $LIB_QUIC-client | jq -r '.[0]."GraphDriver"."Data"."MergedDir"')

if sudo [ ! -d $CONTAINER_ROOT ]
then
    >&2 echo "Unable to find executable. Please, make sure that docker-compose is up."
    exit 1
fi

CMDLINE=$(sudo perf report --header-only -i $1 | grep "cmdline :" | awk -F'-o ' '{ print $2 }' | cut -d ' ' -f 2)

sudo $HOTSPOT_COMMAND --sysroot $CONTAINER_ROOT --kallsyms $CONTAINER_ROOT/tmp/kallsyms --appPath $CONTAINER_ROOT$CMDLINE --extraLibPaths $CONTAINER_ROOT/usr/lib:$CONTAINER_ROOT/$LIB_QUIC/target/performance:$CONTAINER_ROOT/boringssl/lib $1