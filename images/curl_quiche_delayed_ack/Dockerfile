FROM base_boringssl


RUN git clone --branch=delayed_ack --progress https://github.com/mactul/quiche.git /quiche

RUN cd /quiche \
    && QUICHE_BSSL_PATH=/boringssl QUICHE_BSSL_LINK_KIND=dylib cargo build --lib --bin quiche-server --bin quiche-client --features ffi,pkg-config-meta --profile=performance --examples


RUN git clone --branch=quiche --progress https://github.com/mactul/curl.git /curl

RUN cd /curl \
    && autoreconf -fi \
    && ./configure --with-openssl=/boringssl --with-quiche=/quiche/target/performance/ \
    && make -j8

RUN cp /curl/src/curl /curl/src/curl-perf \
    && sed --in-place -e 's|exec "$progdir/$program" ${1+"$@"}|exec hotspot_perf $1 "$progdir/$program" "${@:2}"|g' /curl/src/curl-perf

COPY ./hotspot_perf /usr/local/bin/hotspot_perf
COPY ./quiche-client-default /usr/local/bin/quiche-client-default
COPY ./quiche-client-default-perf /usr/local/bin/quiche-client-default-perf
COPY ./curl-http3-default /usr/local/bin/curl-http3-default
COPY ./curl-http3-default-perf /usr/local/bin/curl-http3-default-perf