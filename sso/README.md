To create a new RH-SSO instance in OpenShift use the following commands:

```
oc new-project sso
oc policy add-role-to-user view system:serviceaccount:$(oc project -q):default
oc create -f https://raw.githubusercontent.com/jboss-openshift/application-templates/master/secrets/sso-app-secret.json
oc new-app --template=sso72-mysql-persistent -p SSO_ADMIN_USERNAME=admin -p SSO_ADMIN_PASSWORD=dummy -p HTTPS_NAME=jboss -p HTTPS_PASSWORD=mykeystorepass
```
