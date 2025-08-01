# p2pool-zero

A secure, zero-footprint Docker image for running [P2Pool](https://github.com/SChernykh/p2pool) — fully rootless, distroless, and built entirely `FROM scratch` for maximum isolation and minimal attack surface.

Hosted image:
📦 [`ghcr.io/lanjelin/p2pool-zero`](https://ghcr.io/lanjelin/p2pool-zero)

---

## 🔐 Security-First Design

This image is built with a focus on container hardening:

* **Built from scratch** — no shell, no package manager, no OS files.
* **Fully static binary** — verified P2Pool release from upstream.
* **Runs as non-root** — `USER 1000:1000` by default.
* Explicitly mounted volumes required for persistence.
* Extremely compact — minimal attack surface, fast startup.

---

## 🧱 What's Inside?

* ✅ [`p2pool`](https://github.com/SChernykh/p2pool) `v4.9`

  * Official precompiled binary verified via GPG and SHA256
  * No shell, no libc, no package manager
* ✅ System CA certificates (for HTTPS peer fetching)

---

## 🚀 Usage

> 🧑 You can override the container user with `--user` if needed to match mounted volume ownership.

Create a local data folder:

```bash
mkdir -p p2pool-data
```

Run the container:

```bash
docker run --rm \
  -v "$(pwd)/p2pool-data:/data" \
  -p 3333:3333 \
  -p 37889:37889 \
  ghcr.io/lanjelin/p2pool-zero \
  --host 127.0.0.1 \
  --rpc-port 18089 \
  --wallet 44...YOUR_MONERO_ADDRESS...abc \
  --stratum 0.0.0.0:3333 \
  --p2p 0.0.0.0:37889
```

This setup:

* Uses your Monero node via `--host` and `--rpc-port`
* Opens standard stratum (3333) and p2p (37889) ports
* Stores peer cache and stats in `./p2pool-data`

> 💡 Replace `--wallet` with your own Monero address or it will default to donating hash rate.

---

## 🧩 Docker Compose

You can also run it with Compose:

```yaml
services:
  p2pool:
    image: ghcr.io/lanjelin/p2pool-zero
    user: "1000:1000"
    volumes:
      - ./p2pool-data:/data
    ports:
      - "3333:3333"
      - "37889:37889"
    command: >
      --host 127.0.0.1
      --rpc-port 18089
      --wallet 44...YOUR_MONERO_ADDRESS...abc
      --stratum 0.0.0.0:3333
      --p2p 0.0.0.0:37889
```

To launch:

```bash
docker-compose up
```

---

## 📁 Volumes

This image requires manual volume mounting — there are no internal writable paths.

### Required:

* `/data` — peer info, stratum cache, stats, etc.

Ensure the mounted `./p2pool-data` folder is writable by UID `1000`.

---

## 🛠️ Build Info

This image is built in **2 stages**:

1. **Builder stage (Debian)**

   * Downloads official P2Pool binary and signature
   * Verifies PGP signature and SHA256 hash
   * Extracts binary and CA certificates

2. **Final `scratch` stage**

   * Copies only `/bin/p2pool` and CA bundle
   * Declares `USER 1000:1000` and entrypoint

No shell, no package manager, no unused files.

---

## 🧪 Building the Image Locally

```bash
git clone https://github.com/lanjelin/p2pool-zero.git
cd p2pool-zero
docker build -t p2pool-zero .
```

> 🔐 GPG key for `SChernykh` is fetched from `keyserver.ubuntu.com` and verified before extracting the release.

---

## 📖 How to Mine

Follow the official mining guide here:
🔗 [How to mine on P2Pool](https://github.com/SChernykh/p2pool#how-to-mine-on-p2pool)

---

## 📜 License

P2Pool is licensed under GPL-3.
This Docker image does not modify the binary and complies with upstream licensing.

---

## 👤 Maintainer

**lanjelin**
Image hosted at [ghcr.io/lanjelin/p2pool-zero](https://ghcr.io/lanjelin/p2pool-zero)

---

