#!/bin/bash

NO_CACHE=
REBUILD_BORINGSSL=

handle_sigint() {
    echo "Removing incomplete files..."
    rm -rf ./common/
    exit 1
}

for i in $@
do
    if [ "$i" = "--no-cache" ]
    then
        NO_CACHE=--no-cache
    elif [ "$i" = "--rebuild-boringssl" ]
    then
        REBUILD_BORINGSSL=--no-cache
    else
        echo "Usage: $0 [--no-cache] [--rebuild-boringssl]"
        echo ""
        printf "\t--rebuild-boringssl:\tClone and rebuild the boringssl image (will take a long time), then process to build the other images.\n"
        printf "\t--no-cache:\t\tRebuild every docker image expect for the boringssl image that is way too long. Use this to re-clone quiche, quiceh and curl repositories.\n"
        exit 1
    fi
done

docker build $REBUILD_BORINGSSL -t base_boringssl ./images/base_boringssl


old_SIGINT_handler=$(trap -p SIGINT)
old_SIGINT_handler=${old_SIGINT_handler:-trap - SIGINT}
trap handle_sigint SIGINT

if [ "$NO_CACHE" = "--no-cache" ] || [ ! -f ./common/certs/cert.key ] || [ ! -f ./common/certs/cert.crt ]
then
    mkdir -p ./common/certs
    openssl req -x509 -newkey rsa:4096 -keyout ./common/certs/cert.key -out ./common/certs/cert.crt -sha256 -days 365 -nodes -subj "/C=XX/ST=StateName/L=CityName/O=CompanyName/OU=CompanySectionName/CN=CommonNameOrHostname"
fi
if [ "$NO_CACHE" = "--no-cache" ] || [ ! -f ./common/public/1G.bin ]
then
    echo "creating 1G.bin..."
    mkdir -p ./common/public
    truncate --size 1G ./common/public/1G.bin
    shred --iterations 1 ./common/public/1G.bin
    echo "..done"
fi
${old_SIGINT_handler}


mkdir -p perf_record/quiceh
mkdir -p perf_record/quiche

docker-compose build $NO_CACHE && docker-compose up