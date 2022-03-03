# Build the manager binary
FROM docker.io/library/golang:1.17-alpine as builder
RUN apk add --no-cache gcc musl-dev linux-headers git

WORKDIR /workspace
RUN git clone https://github.com/ethereum/go-ethereum
WORKDIR /workspace/go-ethereum
RUN git checkout tags/v1.10.16
RUN go run build/ci.go install ./cmd/geth

FROM docker.io/library/alpine:3.15.0
RUN apk add --no-cache ca-certificates

WORKDIR /
COPY --from=builder /workspace/go-ethereum/build/bin/geth .
# USER 65532:65532
EXPOSE 8545 8546 30303 30303/udp

# ENTRYPOINT ["/geth"]
