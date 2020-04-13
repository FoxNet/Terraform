#!/bin/bash
IP_ADDR=$(curl -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/ip)
ZONE=$(curl -H 'Metadata-Flavor: Google' http://metadata.google.internal/computeMetadata/v1/instance/zone | cut -d'/' -f4 | cut -d'-' -f-2)

cat <<EOF> /etc/consul.d/99-bootstrap.json
{
  "server": true,
  "bootstrap": true,
  "datacenter": "gcp-$ZONE"
}
EOF

mv /etc/consul.d/11-generated.json /tmp
jq "del(.primary_datacenter) | .client_addr=\"127.0.0.1 {{ GetPrivateIP }}\"" < /tmp/11-generated.json > /etc/consul.d/11-generated.json
rm /tmp/11-generated.json

mv /etc/vault.d/00-base.json /tmp
jq '.storage[0].consul.token="${consul_bootstrap_token}"' < /tmp/00-base.json | \
jq '.listener[1].tcp={"address": "'$IP_ADDR':8200", "tls_disable": true}' > /etc/vault.d/00-base.json
rm /tmp/00-base.json

cat <<EOF> /etc/vault.d/10-cluster-name.json
{
  "cluster_name": "$ZONE"
}
EOF

systemctl start consul
systemctl start vault

sleep 30s

export CONSUL_HTTP_TOKEN=${consul_bootstrap_token}
consul acl set-agent-token default ${consul_bootstrap_token}

export VAULT_ADDR=http://127.0.0.1:8200
vault operator init \
    -root-token-pgp-key=keybase:reyu \
    -recovery-pgp-keys=keybase:reyu \
    -recovery-shares=1 \
    -recovery-threshold=1 \
    -format=json | \
    consul kv put vault-recovery -
