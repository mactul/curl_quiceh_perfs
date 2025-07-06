FROM base_boringssl


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


COPY ./hotspot_perf /usr/local/bin/hotspot_perf
COPY ./quiceh-client-default /usr/local/bin/quiceh-client-default
COPY ./quiceh-client-default-perf /usr/local/bin/quiceh-client-default-perf
COPY ./curl-http3-default /usr/local/bin/curl-http3-default
COPY ./curl-http3-default-perf /usr/local/bin/curl-http3-default-perf
COPY ./curl-http3-v1-default /usr/local/bin/curl-http3-v1-default
COPY ./curl-http3-v1-default-perf /usr/local/bin/curl-http3-v1-default-perf
COPY ./curl-http2-default /usr/local/bin/curl-http2-default
COPY ./curl-http2-default-perf /usr/local/bin/curl-http2-default-perf