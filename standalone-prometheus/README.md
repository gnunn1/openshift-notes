This details how to deploy a standalone-prometheus for monitoring an application stack rather then the OpenShift cluster.

A set of (instructions)[https://github.com/openshift/origin/tree/master/examples/prometheus] is available in the OpenShift Origin repo, select the branch for the version of OpenShift you are using.

* Create the project, if you use a different project update the namespaces in the secrets we create below:

```oc new-project prometheus```

* The prometheus.yml configmap you need is included here, it was taken from this (template)[https://raw.githubusercontent.com/ConSol/springboot-monitoring-example/master/templates/prometheus3.7_without_clusterrole.yaml]. notice in this file it includes a list of namespaces you want scraped, add any project namespaces to be scraped to the various jobs before creating the map or simply edit the map in OpenShift after creating it.

```oc create secret generic prom --from-file=prometheus.yml```

* The alertmanager.yml configmap is also in this repo:

```oc create secret generic prom-alerts --from-file=alertmanager.yml```

* You must enable the prometheus service account to access any additional namespaces:

```oc policy add-role-to-user view system:serviceaccount:prometheus:prom -n <namespace>```

* Create the prometheus instance:

```oc process -f https://raw.githubusercontent.com/openshift/origin/release-<release>/examples/prometheus/prometheus-standalone.yaml | oc apply -f -```

Replace <release> with the OpenShift release, i.e. 3.10, you are using.
