JanusGraph Docker image
=======================

A Docker image for running JanusGraph.

The following storage back-ends are supported:
* AWS DynamoDB

The following indexing back-ends are supported:
* Elasticsearch


Configuration
-------------

The image can be configured by using the following environment variables:
* **DYNAMODB_REGION**: The DynamoDB region to use. Default: `us-east-1`
* **DYNAMODB_ENDPOINT**: The DynamoDB endpoint to use. Defaults to the endpoint for the region you select.
* **ELASTICSEARCH_HOST**: The Elasticsearch host to connect to. Default: `localhost`
* **ELASTICSEARCH_PORT**: The port on the Elasticsearch host to connect to. Default: `9200`
* **HTTPS_CRT**: A base64 encoded TLS certificate to be used as the server certificate on the HTTP server.
* **HTTPS_KEY**: A base64 encoded TLS private key to be used with the server certificate on the HTTP server.
* **LISTEN_HOST**: The host the HTTP server should listen on. Default: `0.0.0.0`
* **LISTEN_PORT**: The port the HTTP server should listen on. Default: `8182`


Working with this repository
----------------------------

### Prerequisites

- Docker
- docker-compose
- git
- (GNU?) Make
- openssl


### Building

- To build a Docker image, tagged as `janusgraph`, run `make docker`.
- To build everything required to build a Docker image run `make build`.
- To pull down external dependencies without building run `make deps`.


### Running

In order facilitate testing and experimentation, a docker-compose is provided
that runs JanusGraph against a local DynamoDB back-end with an ElasticSearch
instance for indexing.

You can bring the system up with:
```shell
make run
```

You can get a shell by opening another terminal and running:
```shell
make shell
```

Once in, you can use the following command to play with some sample data:
```groovy
:remote connect tinkerpop.server conf/remote.yaml session
:remote console
GraphOfTheGodsFactory.load(graph)
```

We expect an extra command will be required on JanusGraph v0.3.0:
```groovy
g = graph.traversal()
```

You can get some data out with:
```groovy
g.V().has('name', 'pluto').out('lives').in('lives').values('name')
```

Alternatively, you can make requests against gremlin with cURL:
```shell
curl -k -X POST -d "{\"gremlin\":\"g.V().has('name', x).out('lives').in('lives').values('name')\", \"language\":\"gremlin-groovy\", \"bindings\":{\"x\":\"pluto\"}}" "https://localhost:8182"
```


### Testing

In the future it will be possible to acceptance test this repository by running:
```shell
make test
```
