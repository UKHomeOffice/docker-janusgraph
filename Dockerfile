FROM amazonlinux

EXPOSE 8182

RUN yum update -y -q -e 0 \
 && yum upgrade -y -q -e 0 \
 && yum install -y -q \
      java-1.8.0-openjdk \
      openssl \
      shadow-utils \
      unzip

COPY build/janusgraph.zip /

RUN unzip -q /janusgraph.zip -d /var \
 && rm /janusgraph.zip \
 && mv /var/dynamodb-janusgraph-storage-backend-*/ /var/janusgraph

COPY conf/ /var/janusgraph/conf/
COPY docker-entrypoint.sh /var/janusgraph/

RUN adduser -rUM janus -u 31337 -d /var/janusgraph/ \
 && chown -R janus /var/janusgraph/

USER 31337
WORKDIR /var/janusgraph
CMD ["./docker-entrypoint.sh"]
