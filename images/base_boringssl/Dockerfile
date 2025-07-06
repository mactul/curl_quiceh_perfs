FROM rust:latest

RUN apt-get update && apt-get upgrade -y && apt-get install -y build-essential libclang-dev cmake libpsl-dev linux-perf
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