FROM openjdk:8-jre

RUN apt-get update -y -q \
 && apt-get upgrade -y -q \
 && apt-get install -y -q \
      gzip \
      sqlite3 \
      libsqlite3-dev \
      tar \
      wget \
 && mkdir -p /var/dynamodblocal

WORKDIR /var/dynamodblocal
RUN wget https://s3-us-west-2.amazonaws.com/dynamodb-local/dynamodb_local_latest.tar.gz -q -O - | tar -xz
EXPOSE 8000
ENTRYPOINT ["java", "-jar", "DynamoDBLocal.jar", "-inMemory"]