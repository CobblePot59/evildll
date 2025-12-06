FROM debian:bullseye-slim

RUN apt-get update && \
    apt-get install -y \
    mingw-w64 \
    bash \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build
COPY template.cpp /build/
COPY exports.def /build/
COPY entrypoint.sh /build/

RUN chmod +x /build/entrypoint.sh

ENTRYPOINT ["/build/entrypoint.sh"]