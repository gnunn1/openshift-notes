export PROMETHEUS_NAMESPACE=prometheus
export GRAFANA_YAML=https://raw.githubusercontent.com/openshift/origin/release-3.10/examples/grafana/grafana.yaml

datasource_name="prometheus"
sa_reader="prom"

oc new-project grafana

oc adm policy add-cluster-role-to-user cluster-reader grafana

oc process -f "${GRAFANA_YAML}" |oc create -f -
oc rollout status deployment/grafana

echo "Waiting 30 seconds for grafana to be fully up..."
sleep 30

oc adm policy add-role-to-user view -z grafana -n "${PROMETHEUS_NAMESPACE}"

payload="$( mktemp )"
cat <<EOF >"${payload}"
{
"name": "${datasource_name}",
"type": "prometheus",
"typeLogoUrl": "",
"access": "proxy",
"url": "https://$( oc get route prom -n "${PROMETHEUS_NAMESPACE}" -o jsonpath='{.spec.host}' )",
"basicAuth": false,
"withCredentials": false,
"jsonData": {
    "tlsSkipVerify":true,
    "httpHeaderName1":"Authorization"
},
"secureJsonData": {
    "httpHeaderValue1":"Bearer $( oc sa get-token "${sa_reader}" -n "${PROMETHEUS_NAMESPACE}" )"
}
}
EOF

echo "Datasource payload created at ${payload}"

# setup grafana data source
grafana_host="https://$( oc get route grafana -o jsonpath='{.spec.host}' )"
echo "Adding datasource to ${grafana_host}"
curl --insecure -H "Content-Type: application/json" -u admin:admin "${grafana_host}/api/datasources" -X POST -d "@${payload}"
