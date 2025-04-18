FROM caddy:2-builder AS builder

RUN xcaddy build --with github.com/caddyserver/caddy/v2

FROM alpine:latest

RUN apk add --no-cache bash rsync curl jq caddy

COPY --from=builder /usr/bin/caddy /usr/bin/caddy

WORKDIR /app

COPY config/Caddyfile /etc/caddy/Caddyfile
COPY config/shares.list /app/config/shares.list
COPY scripts/*.sh /usr/local/bin/
COPY feeds /app/feeds

RUN chmod +x /usr/local/bin/*.sh

EXPOSE 80

ENTRYPOINT ["/usr/local/bin/run.sh"]
