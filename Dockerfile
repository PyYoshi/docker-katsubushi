FROM golang:1.12-alpine3.9 AS builder

ENV KATSUBUSHI_VERSION=v1.5.4

ENV GO111MODULE=on

RUN \
  apk --no-cache add \
    git \
    bash \
  && mkdir -p /go/src/github.com/kayac \
  && cd /go/src/github.com/kayac \
  && git clone https://github.com/kayac/go-katsubushi.git \
  && cd /go/src/github.com/kayac/go-katsubushi \
  && git checkout $KATSUBUSHI_VERSION \
  && go get \
  && mkdir -p /go/src/github.com/kayac/go-katsubushi/dist \
  && cd /go/src/github.com/kayac/go-katsubushi/cmd/katsubushi \
  && go build -o /go/src/github.com/kayac/go-katsubushi/dist/katsubushi \
  && cd /go/src/github.com/kayac/go-katsubushi/cmd/katsubushi-dump \
  && go build -o /go/src/github.com/kayac/go-katsubushi/dist/katsubushi-dump

FROM alpine:3.9

RUN \
  mkdir -p /opt/katsubushi-server/bin \
  && apk --no-cache add \
    bash

COPY --from=builder /go/src/github.com/kayac/go-katsubushi/dist/katsubushi /katsubushi-server/bin/katsubushi
COPY --from=builder /go/src/github.com/kayac/go-katsubushi/dist/katsubushi-dump /katsubushi-server/bin/katsubushi-dump
COPY ./wait-for-it.sh /opt/katsubushi-server/wait-for-it.sh

RUN \
  chmod +x \
    /katsubushi-server/bin/katsubushi \
    /katsubushi-server/bin/katsubushi-dump \
    /opt/katsubushi-server/wait-for-it.sh
