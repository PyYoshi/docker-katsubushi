FROM golang:1.16.3-buster AS builder

ENV KATSUBUSHI_VERSION=v1.6.0

RUN \
  mkdir -p /go/src/github.com/kayac \
  && cd /go/src/github.com/kayac \
  && git clone https://github.com/kayac/go-katsubushi.git

RUN \
  cd /go/src/github.com/kayac/go-katsubushi \
  && git checkout $KATSUBUSHI_VERSION -b $KATSUBUSHI_VERSION

RUN \
  cd /go/src/github.com/kayac/go-katsubushi \
  && go get -u ./...

RUN \
  mkdir -p /go/src/github.com/kayac/go-katsubushi/dist \
  && cd /go/src/github.com/kayac/go-katsubushi/cmd/katsubushi \
  && go build -o /go/src/github.com/kayac/go-katsubushi/dist/katsubushi

FROM debian:buster-slim

RUN \
  mkdir -p /opt/katsubushi-server/bin

COPY --from=builder /go/src/github.com/kayac/go-katsubushi/dist/katsubushi /opt/katsubushi-server/bin/katsubushi
COPY ./wait-for-it.sh /opt/katsubushi-server/wait-for-it.sh

RUN \
    useradd --create-home --shell /bin/bash katsubushi 

RUN \
  chmod +x \
    /opt/katsubushi-server/bin/katsubushi \
    /opt/katsubushi-server/wait-for-it.sh

USER katsubushi

WORKDIR /opt/katsubushi-server

EXPOSE 11212
