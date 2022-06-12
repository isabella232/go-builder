FROM ubuntu:focal

ARG GO_VERSION=1.18.3
ARG GO_OS=linux
ARG GO_ARCH=amd64

ENV GO_VERSION=$GO_VERSION \
    GOOS=$GO_OS \
    GOARCH=$GO_ARCH \
    GOROOT=/golang/go \
    GOPATH=/golang/go-tools
ENV PATH=$PATH:$GOPATH/bin:$GOROOT/bin

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /tmp/

RUN apt-get update \
    && apt-get -y install --no-install-recommends apt-utils dialog 2>&1 \
    && apt-get -y install \
		    gcc \
        ca-certificates \
        git \
        lsb-release \
        curl \
        jq \
        unzip \
		    make \
		# Clean up
    && apt-get autoremove -y \
    && apt-get clean -y

# install Go
RUN mkdir -p /golang \
    #
    && curl -fsSL https://golang.org/dl/go$GO_VERSION.$GOOS-$GOARCH.tar.gz | tar -C /golang -xzv
RUN go install github.com/axw/gocov/gocov@latest \
    #
    # Install protoc
    && LATEST_PROTOC=`curl -s https://api.github.com/repos/protocolbuffers/protobuf/releases/latest | jq -r ".assets[] | select(.name | test(\"${spruce_type}\")) | .browser_download_url" | grep linux-x86_64.zip` \
    && curl -L -o protoc.zip $LATEST_PROTOC \
    && unzip protoc.zip -d protoc \
    && mv protoc/bin/protoc $GOPATH/bin/protoc \
    && chmod +x $GOPATH/bin/protoc \
    && go install google.golang.org/protobuf/cmd/protoc-gen-go@latest \
    && go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest \
    # Twirp
    && go install github.com/twitchtv/twirp/protoc-gen-twirp@latest \
    # Cleanup
    && rm -Rf /tmp/*

### FINAL ENV
ENV DEBIAN_FRONTEND=dialog
ENV SHELL=/bin/bash

