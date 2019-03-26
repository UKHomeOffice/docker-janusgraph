.PHONY = all build clean docker run

repo_driver_dynamodb = https://github.com/awslabs/dynamodb-janusgraph-storage-backend.git
keysize = 4096

all: docker

build: docker

clean:
	docker-compose down -v || true
	rm -rf .docker-compose

docker:
	docker build -t 'janusgraph' .

run: .env
	docker-compose up --build

shell:
	docker exec -i -t "$$(basename $${PWD})_janusgraph_1" /var/janusgraph/bin/gremlin.sh

test:
	echo 'NOT YET IMPLEMENTED' && false

.env: .docker-compose/janusgraph.crt .docker-compose/janusgraph.key
	bash .env.sh > .env

%.key:
	mkdir -p '$(@D)'
	openssl genrsa -out '$@' '$(keysize)'

%.crt: %.key
	mkdir -p '$(@D)'
	openssl req \
		-new \
		-x509 \
		-sha256 \
		-days 365 \
		-key '$(<)' \
		-subj '/CN=$(notdir $(basename $(@)))' \
		-out '$(@)'
