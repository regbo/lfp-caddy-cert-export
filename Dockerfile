FROM caddy:builder AS builder

RUN xcaddy build \
    --with github.com/caddy-dns/cloudflare \
    --with github.com/mholt/caddy-events-exec

FROM caddy:latest

COPY --from=builder /usr/bin/caddy /usr/bin/caddy

RUN apk add --no-cache bash jq

RUN wget https://github.com/a8m/envsubst/releases/download/v1.2.0/envsubst-`uname -s`-`uname -m` -O envsubst && \
    chmod +x envsubst && \
    mv envsubst /usr/local/bin

COPY run_caddy.sh /run_caddy.sh
RUN chmod +x /run_caddy.sh

COPY cert_obtained.sh /cert_obtained.sh
RUN chmod +x /cert_obtained.sh

COPY caddy.config.template.json /caddy.config.template.json

CMD ["/run_caddy.sh"]