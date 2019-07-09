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
  && cd /go/src/github.com/kayac/katsubushi \
  && git checkout $KATSUBUSHI_VERSION \
  && go get \
  && mkdir -p /go/src/github.com/kayac/katsubushi/dist \
  && cd /go/src/github.com/kayac/katsubushi/cmd/katsubushi \
  && go build -o /go/src/github.com/kayac/katsubushi/dist/katsubushi \
  && cd /go/src/github.com/kayac/katsubushi/cmd/katsubushi-dump \
  && go build -o /go/src/github.com/kayac/katsubushi/dist/katsubushi-dump

FROM alpine:3.9

RUN \
  mkdir -p /opt/katsubushi/bin

COPY --from=builder /go/src/github.com/kayac/katsubushi/dist/katsubushi /usr/local/bin/katsubushi
COPY --from=builder /go/src/github.com/kayac/katsubushi/dist/katsubushi-dump /usr/local/bin/katsubushi-dump

RUN \
  chmod +x /usr/local/bin/katsubushi /usr/local/bin/katsubushi-dump

ENTRYPOINT ["/usr/local/bin/katsubushi"]
