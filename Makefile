DOCKER_IMAGE ?= janusgraph

repo_driver_dynamodb = https://github.com/awslabs/dynamodb-janusgraph-storage-backend.git
keysize = 4096

mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
current_dir := $(notdir $(patsubst %/,%,$(dir $(mkfile_path))))
compose_project_name = $(current_dir)
compose_network_regexp != echo "$$(echo '$(compose_project_name)' | sed -E 's/([-_])+/[-_]*/g')_default"
probe_network = docker network ls | grep -o '$(compose_network_regexp)'
probe_gremlin = docker run --net "$${compose_network}" --rm 'byrnedo/alpine-curl' -kfs 'https://janusgraph:8182/?gremlin=1' &> /dev/null

.PHONY = all build clean deps docker run test

all: docker

build: build/janusgraph.zip

clean:
	docker-compose down -v || true
	rm -rf .docker-compose/
	rm -rf deps/
	rm -rf build/

deps: deps/dynamodb-janusgraph-storage-backend/

docker: build/janusgraph.zip
	docker build -t '$(DOCKER_IMAGE)' .

run: build/janusgraph.zip .env
	docker-compose up --build

shell:
	docker exec -i -t "$$(basename $${PWD})_janusgraph_1" /var/janusgraph/bin/gremlin.sh

test: build/janusgraph.zip
	@echo 'Taking down any previous test environment'
	docker-compose -f docker-compose-test.yml -p '$(compose_project_name)' down -v
	@echo 'Building images'
	docker-compose -f docker-compose-test.yml -p '$(compose_project_name)' build
	@echo 'Starting new test environment'
	docker-compose -f docker-compose-test.yml -p '$(compose_project_name)' up &> /dev/null &
	echo 'Waiting for Docker network'; \
	compose_network=`$(probe_network)`; \
	while [ $$? -ne 0 ]; do \
		echo ...; \
		sleep 5; \
		compose_network=`$(probe_network)`; \
	done; \
	echo 'Waiting for Gremlin'; \
	$(probe_gremlin); \
	while [ $$? -ne 0 ]; do \
		echo ...; \
		sleep 5; \
		$(probe_gremlin); \
	done; \
	echo 'Starting tests'; \
	docker run --net "$${compose_network}" --rm 'byrnedo/alpine-curl' -kfs -X POST -d '{"gremlin":"x+x", "language":"gremlin-groovy", "bindings":{"x":1}}' 'https://janusgraph:8182/' | jq -e '.result.data == [2]'
	@echo 'Tests complete; bringing down test environment'
	docker-compose -f docker-compose-test.yml -p '$(compose_project_name)' down -v

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
