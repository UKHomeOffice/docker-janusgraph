FROM openjdk:8-jre-alpine

ENV LISTEN_HOST="0.0.0.0" \
    LISTEN_PORT="8182"
EXPOSE 8182

RUN apk upgrade -q --no-cache
RUN apk add -q --no-cache \
      bash \
      ca-certificates \
      gettext \
      gnupg \
      nss \
      openssl \
      shadow \
      unzip

COPY build/janusgraph.zip /

RUN unzip -q /janusgraph.zip -d /var \
 && rm /janusgraph.zip \
 && mv /var/dynamodb-janusgraph-storage-backend-*/ /var/janusgraph

COPY conf/ /var/janusgraph/conf-templates/
COPY docker-entrypoint.sh /var/janusgraph/

RUN adduser -S janus -u 31337 -h /var/janusgraph/ \
 && chown -R janus /var/janusgraph/

USER 31337
WORKDIR /var/janusgraph
CMD ["./docker-entrypoint.sh"]
