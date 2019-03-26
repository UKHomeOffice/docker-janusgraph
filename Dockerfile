FROM maven:3.6-jdk-8-alpine as builder

ARG REPO_DRIVER_DYNAMODB=https://github.com/awslabs/dynamodb-janusgraph-storage-backend.git
ARG DYNAMODB_VERSION=jg0.2.0-1.2.0

RUN apk upgrade -q --no-cache
RUN apk add -q --no-cache \
      git \
      bash \
      ca-certificates \
      gettext \
      gnupg \
      nss \
      openssl \
      shadow \
      unzip \
      zip

RUN git clone --single-branch -b $DYNAMODB_VERSION $REPO_DRIVER_DYNAMODB /opt/dynamodb-janusgraph-storage-backend/
WORKDIR /opt/dynamodb-janusgraph-storage-backend/
RUN ./src/test/resources/install-gremlin-server.sh


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

COPY --from=builder /opt/dynamodb-janusgraph-storage-backend/server/janusgraph-*.zip /janusgraph.zip

RUN unzip -q /janusgraph.zip -d /var \
 && rm /janusgraph.zip \
 && mv /var/janusgraph-*/ /var/janusgraph

COPY conf/ /var/janusgraph/conf-templates/
COPY docker-entrypoint.sh /var/janusgraph/

RUN adduser -S janus -u 31337 -h /var/janusgraph/ \
 && chown -R janus /var/janusgraph/

USER 31337
WORKDIR /var/janusgraph
CMD ["./docker-entrypoint.sh"]
