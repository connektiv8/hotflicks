# docker/search/Dockerfile.meilisearch
FROM alpine:3.21

ARG MEILISEARCH_VERSION

RUN apk add --no-cache \
    curl \
    ca-certificates \
    && curl -L "https://install.meilisearch.com/${MEILISEARCH_VERSION}/linux-amd64" -o /usr/local/bin/meilisearch \
    && chmod +x /usr/local/bin/meilisearch

COPY search/configs/meilisearch.toml /etc/meilisearch/config.toml

EXPOSE 7700

CMD ["/usr/local/bin/meilisearch", "--config-file-path", "/etc/meilisearch/config.toml"]