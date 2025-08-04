# === Stage 1: Download, verify and extract ===
ARG BUILD_TAG=v4.9

FROM debian:bullseye-slim AS builder-p2pool

ARG BUILD_TAG
ARG p2pool_url=https://github.com/SChernykh/p2pool

RUN apt update && \
    apt install -y --no-install-recommends wget gpg dirmngr gnupg ca-certificates && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /build

RUN wget "$p2pool_url/releases/download/$BUILD_TAG/p2pool-$p2pool_tag-linux-x64.tar.gz" && \
    wget "$p2pool_url/releases/download/$BUILD_TAG/sha256sums.txt.asc" && \
    gpg --keyserver keyserver.ubuntu.com --recv-keys C47F82B54DA87ADF && \
    gpg --output sha256sums.txt --decrypt sha256sums.txt.asc || { echo "Signature verification or decryption failed"; exit 1; } && \
    expected=$(grep -A2 "Name: p2pool-$BUILD_TAG-linux-x64.tar.gz" sha256sums.txt | grep SHA256 | awk '{print $2}') && \
    echo "$expected  p2pool-$BUILD_TAG-linux-x64.tar.gz" | sha256sum --check || { echo "Hash mismatch!"; exit 1; } && \
    tar xfz p2pool-$BUILD_TAG-linux-x64.tar.gz --strip-components=1

# === Stage 2: Minimal p2pool runtime ===
FROM scratch
ARG BUILD_TAG

LABEL org.opencontainers.image.title="p2pool-zero" \
      org.opencontainers.image.description="A rootless, distroless, from-scratch Docker image for running p2pool." \
      org.opencontainers.image.url="https://ghcr.io/lanjelin/p2pool-zero" \
      org.opencontainers.image.source="https://github.com/Lanjelin/p2pool-zero" \
      org.opencontainers.image.documentation="https://github.com/Lanjelin/p2pool-zero" \
      org.opencontainers.image.version="$BUILD_TAG" \
      org.opencontainers.image.authors="Lanjelin" \
      org.opencontainers.image.licenses="GPL-3"

USER 1000:1000
COPY --from=builder-p2pool /build/p2pool /bin/p2pool
COPY --from=builder-p2pool /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt

EXPOSE 3333
EXPOSE 37889

ENTRYPOINT ["/bin/p2pool"]
