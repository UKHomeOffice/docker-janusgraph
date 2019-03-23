.PHONY = all build clean deps docker

repo_driver_dynamodb = https://github.com/awslabs/dynamodb-janusgraph-storage-backend.git

all: docker

build: build/janusgraph.zip

clean:
	rm -rf deps/
	rm -rf build/

deps: deps/dynamodb-janusgraph-storage-backend/

docker: build/janusgraph.zip
	docker build -t janusgraph .

deps/dynamodb-janusgraph-storage-backend/:
	mkdir -p '$(@D)'
	git clone --single-branch -b 'master' '$(repo_driver_dynamodb)' '$(@)'

build/janusgraph.zip: deps/dynamodb-janusgraph-storage-backend/
	mkdir -p '$(@D)'
	rm -rf 'deps/dynamodb-janusgraph-storage-backend/server/'
	cd 'deps/dynamodb-janusgraph-storage-backend/' && ./src/test/resources/install-gremlin-server.sh
	cp deps/dynamodb-janusgraph-storage-backend/server/dynamodb-janusgraph-storage-backend-*.zip '$(@)'
