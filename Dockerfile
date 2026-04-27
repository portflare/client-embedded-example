# CLIENT_IMAGE should point at a published Portflare client image.
ARG CLIENT_IMAGE=ghcr.io/portflare/client:latest
FROM ${CLIENT_IMAGE} AS client

FROM node:22-bookworm-slim
WORKDIR /app
RUN npm install -g http-server
COPY --from=client /usr/local/bin/reverse-client /usr/local/bin/reverse-client
COPY bin/embedded-entrypoint.sh /usr/local/bin/embedded-entrypoint.sh
RUN chmod +x /usr/local/bin/embedded-entrypoint.sh
RUN printf '%s\n' '<!doctype html><html><body><h1>Portflare embedded example</h1></body></html>' > /app/index.html
ENV REVERSE_CLIENT_LISTEN_ADDR=127.0.0.1:9901
ENV REVERSE_CLIENT_DISCOVER=true
ENV REVERSE_CLIENT_DISCOVER_ALLOW=3000
ENV REVERSE_CLIENT_DISCOVER_DENY=22,2375,2376
ENV REVERSE_CLIENT_DISCOVER_NAMES=3000=web
EXPOSE 3000
ENTRYPOINT ["/usr/local/bin/embedded-entrypoint.sh"]
CMD ["http-server", ".", "-p", "3000"]
