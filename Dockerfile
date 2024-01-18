# Official Debian runtime as a base image
FROM debian:latest

WORKDIR /starch-mine

RUN apt-get update && \
    apt-get install -y curl jq procps && \
    rm -rf /var/lib/apt/lists/*

COPY tatertots.sh /starch-mine/tatertots.sh
COPY miner.conf /starch-mine/miner.conf
RUN chmod +x /starch-mine/tatertots.sh
ENV TERM xterm
CMD ["./tatertots.sh"]