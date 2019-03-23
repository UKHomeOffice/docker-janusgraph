#! /bin/env bash

cat << EOF
JANUSGRAPH_CRT=`cat .docker-compose/janusgraph.crt | base64 | tr -d '\n'`
JANUSGRAPH_KEY=`cat .docker-compose/janusgraph.key | base64 | tr -d '\n'`
EOF
