FROM alpine:3.12 as downloader

ENV LANG C.UTF-8
ENV TZ Europe/Berlin

# Download latest version of TS Server and unpack it to /tmp/teamspeak3-server_linux_alpine
RUN apk add --no-cache bzip2 w3m &&\
  TS_SERVER_VER="$(w3m -dump https://www.teamspeak.com/downloads | grep -m 1 'Server 64-bit ' | awk '{print $NF}')" && \
  mkdir -p /tmp && \
  wget https://files.teamspeak-services.com/releases/server/${TS_SERVER_VER}/teamspeak3-server_linux_alpine-${TS_SERVER_VER}.tar.bz2 -O /tmp/teamspeak.tar.bz2 &&\
  tar jxf /tmp/teamspeak.tar.bz2 -C /tmp



FROM alpine:3.12 as prod

# add start
COPY entrypoint.sh /entrypoint.sh

# Install needed packages to run the server
RUN apk add --no-cache libstdc++ tini

# Copy app
COPY --from=downloader /tmp/teamspeak3-server_linux_alpine /app

# Add user and give him rights to the app and data
RUN adduser -u 503 -g 503 -D -h /app teamspeak \
    && mkdir /data \
    && chown -R teamspeak:teamspeak /app /data

USER teamspeak
EXPOSE 9987/udp 10011 30033 41144

ENTRYPOINT ["/entrypoint.sh"]
