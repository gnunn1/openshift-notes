To create a new RH-SSO instance in OpenShift use the commands below:

```
oc new-project sso
oc policy add-role-to-user view system:serviceaccount:$(oc project -q):default
oc create -f https://raw.githubusercontent.com/jboss-openshift/application-templates/master/secrets/sso-app-secret.json
oc new-app --template=sso73-mysql-persistent -p SSO_ADMIN_USERNAME=admin -p SSO_ADMIN_PASSWORD=dummy -p HTTPS_NAME=jboss -p HTTPS_PASSWORD=mykeystorepass
```

If you want to use the letsencrypt certificate you generated for the OpenShift wildcard with RH-SSO, use the following steps:

```
# The wildcard for your OpenShift installation
export OCP_WILDCARD_DOMAIN=apps.ocplab.com

# Convert letsencrypt certs to a p12 file (silly java Keytool don't have an option to import a private key, it needs to be bundled in a p12 file):
openssl pkcs12 -export -in fullchain.pem -inkey key.pem -out pkcs.p12 -name test

# Create SSL keystore
keytool -importkeystore -deststorepass password -destkeypass password -destkeystore keystore.jks -srckeystore pkcs.p12 -srcstoretype PKCS12 -srcstorepass test -alias test

# Create jgroups keystore
keytool -genseckey -alias jgroups -storetype JCEKS -keystore jgroups.jceks -storepass password -keypass password

# Create OpenShift Secret
oc create secret generic sso-app-secret --from-file=keystore.jks --from-file=jgroups.jceks

# Create application
oc new-app --template=sso73-mysql-persistent -p SSO_ADMIN_USERNAME=admin -p SSO_ADMIN_PASSWORD=admin -p HTTPS_NAME=test -p HTTPS_PASSWORD=password -p JGROUPS_ENCRYPT_PASSWORD=password -p HOSTNAME_HTTPS=secure-sso-$(oc project -q).$OCP_WILDCARD_DOMAIN
```

In OpenShift 4, to make SSO more attractive in the Topology view:
```
oc label dc sso-mysql app.openshift.io/runtime=mysql-database
oc label dc sso-mysql app.kubernetes.io/component=database --overwrite
oc label dc sso-mysql app.kubernetes.io/instance=sso-db --overwrite
oc label dc sso app.openshift.io/runtime=sso

oc annotate dc/sso app.openshift.io/connects-to=sso-db

```
