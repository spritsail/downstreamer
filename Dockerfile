ARG JO_VER=1.1
ARG DOWNSTREAMER_VER=1.0

FROM alpine:3.7 as builder

ARG JO_VER

ENV CFLAGS="-Os -pipe -fstack-protector-strong" \
    LDFLAGS="-Wl,-O1,--sort-common -Wl,-s"

WORKDIR /tmp

RUN apk add -U libc-dev gcc make \
 && wget -O- https://github.com/jpmens/jo/releases/download/v1.1/jo-1.1.tar.gz | \
    tar xz --strip-components=1 \
 && ./configure \
 && make all \
 && make check

# =============

FROM spritsail/webhook

ARG JO_VER
ARG DOWNSTREAMER_VER

LABEL maintainer="Spritsail <downstreamer@spritsail.io>" \
      org.label-schema.vendor="Spritsail" \
      org.label-schema.name="Dowstreamer" \
      org.label-schema.url="https://github.com/spritsail/downstreamer" \
      org.label-schema.description="Manage Drone downstream builds, and build notifications" \
      org.label-schema.version=${DOWNSTREAMER_VER} \
      io.spritsail.version.jo=${JO_VER} \
      io.spritsail.version.downstreamer=${DOWNSTREAMER_VER}

ENV PATH=$PATH:/downstream

WORKDIR /downstream

COPY --from=builder /tmp/jo /usr/bin/jo
COPY src/ /downstream

RUN apk add -U --no-cache jq

VOLUME ["/config"]

CMD ["-verbose", "-hooks", "/downstream/hooks.json", "-template", "-hotreload"]

