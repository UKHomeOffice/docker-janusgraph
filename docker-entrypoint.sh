#! /bin/bash

set -euo pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

pki_dir="/dev/shm/pki/"
pki_crt="${pki_dir}/janusgraph.crt"
pki_key="${pki_dir}/janusgraph.key"
pki_pk8="${pki_dir}/janusgraph.pk8"

function mandatoryCheck () {
    if [[ -z "${1}" ]]; then
        echo "You must set ${2}" && exit 1;
    fi
}

# Install certs if provided
mkdir -p "${pki_dir}"
if [[ -n "${HTTPS_CRT}" ]]; then
    # Use provided key-pair
    mandatoryCheck "${HTTPS_KEY}" "HTTPS_KEY"

    echo -n "${HTTPS_CRT}" | base64 -d > "${pki_crt}"
    echo -n "${HTTPS_KEY}" | base64 -d > "${pki_key}"
else
    # No key-pair provided so auto-generate one
	  openssl genrsa -out "${pki_key}" 4096
	  openssl req \
		        -new \
		        -x509 \
		        -sha256 \
		        -days 365 \
		        -key "${pki_key}" \
		        -subj "/CN=${HOSTNAME}" \
		        -out "${pki_crt}"
fi

openssl pkcs8 -topk8 -nocrypt -inform PEM -outform PEM -in "${pki_key}" -out "${pki_pk8}"

# Start Gremlin server
"/var/janusgraph/bin/gremlin-server.sh" "./conf/gremlin-server/gremlin-server.yaml"
