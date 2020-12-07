FROM alpine:latest as torbuilder
ARG tor_version

RUN apk add --no-cache build-base git autoconf automake zlib-static openssl-libs-static libevent-static libevent-dev zlib-dev openssl-dev

RUN git clone --branch tor-$tor_version --depth 1 https://git.torproject.org/tor.git

RUN cd tor \
        && ./autogen.sh \
        && ./configure --disable-asciidoc --sysconfdir=/etc --disable-unittests \
            --enable-static-tor \
            --with-openssl-dir=/usr/lib \
            --with-libevent-dir=/usr/lib \
            --with-zlib-dir=/lib \
        && make \
        && make install

FROM alpine:latest

ENV HOME /var/lib/tor

RUN mkdir -p /etc/tor/ ${HOME}/.tor && \
    addgroup -S -g 107 tor && \
    adduser -S -G tor -u 104 -H -h ${HOME} tor

COPY assets/onions /usr/local/src/onions
COPY assets/torrc /var/local/tor/torrc.tpl

RUN apk add --no-cache musl-dev gcc py-setuptools python3 python3-dev \
        && cd /usr/local/src/onions && python3 setup.py install \
        && apk del gcc musl-dev py-setuptools python3-dev

COPY --from=torbuilder /usr/local/bin/tor /usr/local/bin
COPY assets/entrypoint-config.yml /

ENTRYPOINT ["pyentrypoint"]

CMD ["tor"]
