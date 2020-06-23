# based on linux.Dockerfile
# see https://blog.jetbrains.com/go/2020/05/06/debugging-a-go-application-inside-a-docker-container/

FROM golang:1.12-buster as builder

RUN apt-get update && apt-get install -y \
  git \
  bash \
  curl

ENV CGO_ENABLED=0
# GOFLAGS=-mod=vendor

RUN go get github.com/go-delve/delve/cmd/dlv

WORKDIR /pebble-src
COPY . .

#RUN go install -v ./cmd/pebble/...
RUN go install -gcflags="all=-N -l" -v ./cmd/pebble/...

## main -------------------------------------------
FROM debian:buster

RUN apt-get update && apt-get install -y \
  ca-certificates

COPY --from=builder /go/bin/dlv /usr/bin/dlv
COPY --from=builder /go/bin/pebble /usr/bin/pebble
COPY --from=builder /pebble-src/test/ /test/

# CMD [ "/usr/bin/pebble" ]
EXPOSE 40000
CMD ["/usr/bin/dlv", "--listen=:40000", "--headless=true", "--api-version=2", "--accept-multiclient", "exec", "/usr/bin/pebble"]

EXPOSE 14000
EXPOSE 15000

