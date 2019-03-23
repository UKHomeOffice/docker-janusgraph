JanusGraph Docker image
=======================

A Docker image for running JanusGraph.

The following storage back-ends are supported:
* AWS DynamoDB

The following indexing back-ends are supported:
* ElasticSearch


Configuration
-------------

The image can be configured by using the following environment variables:
* **HTTPS_CRT**: A base64 encoded TLS certificate to be used as the server certificate on the HTTP server.
* **HTTPS_KEY**: A base64 encoded TLS private key to be used with the server certificate on the HTTP server.


Building
--------

- To build a Docker image, tagged as `janusgraph`, run `make docker`.
- To build everything required to build a Docker image run `make build`.
- To pull down external dependencies without building run `make deps`.
