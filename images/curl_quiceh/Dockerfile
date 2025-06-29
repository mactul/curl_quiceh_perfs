FROM rust:latest

RUN apt-get update && apt-get upgrade -y && apt-get install -y lsb-release

RUN curl -k https://nginx.org/keys/nginx_signing.key | gpg --dearmor \
    | tee /usr/share/keyrings/nginx-archive-keyring.gpg >/dev/null

RUN gpg --dry-run --quiet --no-keyring --import --import-options import-show /usr/share/keyrings/nginx-archive-keyring.gpg

RUN echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] http://nginx.org/packages/debian `lsb_release -cs` nginx" \
    | tee /etc/apt/sources.list.d/nginx.list

RUN printf "Package: *\nPin: origin nginx.org\nPin: release o=nginx\nPin-Priority: 900\n" \
    | tee /etc/apt/preferences.d/99nginx

RUN apt-get update && apt-get install -y build-essential cmake libpsl-dev linux-perf nginx
RUN apt-get remove --purge -y curl


RUN git clone --single-branch --progress https://boringssl.googlesource.com/boringssl /boringssl \
    && cd /boringssl \
    && mkdir -p build

RUN cd /boringssl/build \
    && sed --in-place -e 's/-Werror//g' /boringssl/CMakeLists.txt \
    && cmake --compile-no-warning-as-error -DCMAKE_POSITION_INDEPENDENT_CODE=on -DBUILD_SHARED_LIBS=1 -DCMAKE_BUILD_TYPE=Release .. \
    && make -j8 \
    && cd .. \
    && mkdir -p lib \
    && cp build/*.so lib/


RUN git clone --progress --branch=benchmark https://github.com/mactul/quiceh.git /quiceh

RUN cd /quiceh \
    && QUICHE_BSSL_PATH=/boringssl QUICHE_BSSL_LINK_KIND=dylib cargo build --lib --bin quiceh-server --bin quiceh-client --features ffi,pkg-config-meta --profile=performance --examples


RUN git clone --single-branch --progress https://github.com/mactul/curl.git /curl

RUN cd /curl \
    && autoreconf -fi \
    && ./configure --with-openssl=/boringssl --with-quiceh=/quiceh/target/performance/ \
    && make -j8

RUN cp /curl/src/curl /curl/src/curl-perf \
    && sed --in-place -e 's|exec "$progdir/$program" ${1+"$@"}|exec hotspot_perf $1 "$progdir/$program" "${@:2}"|g' /curl/src/curl-perf


RUN mkdir -p /certs/ \
    && openssl req -x509 -newkey rsa:4096 -keyout /certs/cert.key -out /certs/cert.crt -sha256 -days 365 -nodes -subj "/C=XX/ST=StateName/L=CityName/O=CompanyName/OU=CompanySectionName/CN=CommonNameOrHostname"

RUN mkdir -p /public \
    && truncate --size 1G /public/1G.bin \
    && shred --iterations 1 /public/1G.bin

COPY nginx.conf /etc/nginx/nginx.conf

COPY ./hotspot_perf /usr/local/bin/hotspot_perf
COPY ./quiceh-client-default /usr/local/bin/quiceh-client-default
COPY ./quiceh-client-default-perf /usr/local/bin/quiceh-client-default-perf
COPY ./curl-http3-default /usr/local/bin/curl-http3-default
COPY ./curl-http3-default-perf /usr/local/bin/curl-http3-default-perf
COPY ./curl-http2-default /usr/local/bin/curl-http2-default
COPY ./curl-http2-default-perf /usr/local/bin/curl-http2-default-perf