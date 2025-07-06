NO_CACHE=

for i in $@
do
    if [ $i == "--no-cache" ]
    then
        NO_CACHE=--no-cache
    fi
done

docker build $NO_CACHE -t base_boringssl ./images/base_boringssl

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

mkdir -p perf_record/quiceh
mkdir -p perf_record/quiche

docker-compose build $NO_CACHE && docker-compose up