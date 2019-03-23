.PHONY = all build clean deps docker run

repo_driver_dynamodb = https://github.com/awslabs/dynamodb-janusgraph-storage-backend.git
keysize = 4096

all: docker

build: build/janusgraph.zip

clean:
	docker-compose down -v || true
	rm -rf .docker-compose/
	rm -rf deps/
	rm -rf build/

deps: deps/dynamodb-janusgraph-storage-backend/

docker: build/janusgraph.zip
	docker build -t 'janusgraph' .

run: build/janusgraph.zip .env
	docker-compose up --build

shell:
	docker exec -i -t "$$(basename $${PWD})_janusgraph_1" /var/janusgraph/bin/gremlin.sh

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

deps/dynamodb-janusgraph-storage-backend/:
	mkdir -p '$(@D)'
	git clone --single-branch -b 'master' '$(repo_driver_dynamodb)' '$(@)'

build/janusgraph.zip: deps/dynamodb-janusgraph-storage-backend/
	mkdir -p '$(@D)'
	rm -rf 'deps/dynamodb-janusgraph-storage-backend/server/'
	cd 'deps/dynamodb-janusgraph-storage-backend/' && ./src/test/resources/install-gremlin-server.sh
	cp deps/dynamodb-janusgraph-storage-backend/server/dynamodb-janusgraph-storage-backend-*.zip '$(@)'
