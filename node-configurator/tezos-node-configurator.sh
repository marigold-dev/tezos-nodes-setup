#!/bin/sh
set -ex

# throw error if TEZOS_NETWORK and HISTORY_MODE are not set
if [ -z "$TEZOS_NETWORK" ]; then
    echo "TEZOS_NETWORK is not set"
    exit 1
fi
if [ -z "$HISTORY_MODE" ]; then
    echo "HISTORY_MODE is not set"
    exit 1
fi

CONNECTION_TIMEOUT=${CONNECTION_TIMEOUT:=10}
MIN_CONNECTIONS=${MIN_CONNECTIONS:=10}
EXPECTED_CONNECTIONS=${MAX_CONNECTIONS:=50}
MAX_CONNECTIONS=${MAX_CONNECTIONS:=100}
MAX_KNOWN_POINTS_MAX=${MAX_KNOWN_POINTS_MAX:=400}
MAX_KNOWN_POINTS_TARGET=${MAX_KNOWN_POINTS_TARGET:=300}
MAX_KNOWN_PEER_IDS_MAX=${MAX_KNOWN_PEER_IDS_MAX:=400}
MAX_KNOWN_PEER_IDS_TARGET=${MAX_KNOWN_PEER_IDS_TARGET:=300}
SYNCHRONISATION_THRESHOLD=${SYNCHRONISATION_THRESHOLD:=1}

CORS_ENABLED=${CORS_ENABLED:-true}
bin_dir="/usr/local/bin"
data_dir="/var/run/tezos"
node_dir="$data_dir/node"
client_dir="$data_dir/client"
node="$bin_dir/octez-node"
node_data_dir="$node_dir/data"

# Network as a link should be converted to a json object
network=\"$TEZOS_NETWORK\"
if [[ "$TEZOS_NETWORK" =~ ^http.* ]]; then
    network=$(wget -qO- $TEZOS_NETWORK)
fi
echo $network

echo "Writing custom configuration for public node\n"
# why hard-code this file ?
# Reason 1: we could regenerate it from scratch with cli but it requires doing tezos-node config init or tezos-node config reset, depending on whether this file is already here
# Reason 2: the --connections parameter automatically puts the number of minimal connections to half that of expected connections, resulting in logs spewing "Not enough connections (2)" all the time. Hard-coding the config file solves this.

rm -rvf ${node_dir}/data/config.json
mkdir -p ${node_dir}/data
cat << EOF > ${node_dir}/data/config.json
{ "data-dir": "/var/run/tezos/node/data",
  "network": $network,
  "metrics_addr": [ "0.0.0.0:9932" ],
  "rpc":
    {
      "listen-addrs": [ "0.0.0.0:8732", ":8732"],
      $([ "$CORS_ENABLED" = true ] && echo '"cors-origin": ["*"],
      "cors-headers": ["Content-Type"],')
      "acl":
        [ { "address": "0.0.0.0:8732", "blacklist": [] }, { "address": "127.0.0.1:8732", "blacklist": [] }
        ]
    },
  "p2p":{
    "limits":{
      "connection-timeout":$CONNECTION_TIMEOUT,
      "min-connections":$MIN_CONNECTIONS,
      "expected-connections":$EXPECTED_CONNECTIONS,
      "max-connections":$MAX_CONNECTIONS,
      "max_known_points":[$MAX_KNOWN_POINTS_MAX, $MAX_KNOWN_POINTS_TARGET],
      "max_known_peer_ids":[$MAX_KNOWN_PEER_IDS_MAX, $MAX_KNOWN_PEER_IDS_TARGET]
    }
  },
  "shell":{
    "chain_validator":{
      "synchronisation_threshold":$SYNCHRONISATION_THRESHOLD
    },
    "history_mode":"$HISTORY_MODE"
  }
}
EOF

cat ${node_dir}/data/config.json

# Generate a new identity if not present
if [ ! -f "$node_data_dir/identity.json" ]; then
    echo "Generating a new node identity..."
    exec "${node}" identity generate "${IDENTITY_POW:-26}". \
            --data-dir "$node_data_dir"
fi
