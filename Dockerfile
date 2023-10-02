FROM alpine:3.17.0

RUN apk update && \
    apk add --no-cache \
    build-base=0.5-r3 \
    cmake \
    gcc-arm-none-eabi \
    newlib-arm-none-eabi\
    binutils-arm-none-eabi

COPY . .

USER root
# Add again root CA with `update-ca-certificates` tool
RUN apk --no-cache add ca-certificates \
    && rm -rf /var/cache/apk/*
COPY ./cert/cert.pem /root/my-root-ca.crt
COPY ./cert/cert.pem /usr/local/share/ca-certificates/
RUN update-ca-certificates