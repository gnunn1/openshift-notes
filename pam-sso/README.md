This documents how to deploy the authoring template on OpenShift using RH-SSO. It assumes
that RH-SSO has been deployed into an sso project using the notes in the sso folder of
this repo. The instructions here re-use the sso keystore since it's a wildcard certificate.

In the SSO server, import the pam realm from ```real-export.json```

```
oc new-project pam

# Re-use the keystore.jks created in SSO steps
oc create secret generic kieserver-app-secret --from-file=keystore.jks
oc create secret generic businesscentral-app-secret --from-file=keystore.jks

# Note if deploying on OpenShift and you don't have RWX, modify template to change ReadWriteMany to ReadWriteOnce. Note you cannot scale kieserver after this change

oc new-app -f templates/rhpam76-authoring.yaml -p APPLICATION_NAME=pam \
  -p KIE_ADMIN_USER=kieadmin -p KIE_ADMIN_PWD=openshift \
  -p KIE_SERVER_USER=kieserver -p KIE_SERVER_PWD=openshift \
  -p SSO_URL=https://secure-sso-sso.apps.cluster.ocplab.com/auth -p SSO_REALM=pam \
  -p BUSINESS_CENTRAL_SSO_CLIENT=bc -p BUSINESS_CENTRAL_SSO_SECRET=f22af19d-bdae-421b-80b2-dc43e9e4e64f \
  -p KIE_SERVER_SSO_CLIENT=kie -p KIE_SERVER_SSO_SECRET=f22af19d-bdae-421b-80b2-dc43e9e4e64f \
  -p SSO_USERNAME=admin -p SSO_PASSWORD=openshift \
  -p BUSINESS_CENTRAL_HTTPS_SECRET=businesscentral-app-secret -p BUSINESS_CENTRAL_HTTPS_NAME=test -p BUSINESS_CENTRAL_HTTPS_PASSWORD=password \
  -p KIE_SERVER_HTTPS_SECRET=kieserver-app-secret -p KIE_SERVER_HTTPS_NAME=test -p KIE_SERVER_HTTPS_PASSWORD=password

```

To add process automation images in Developer topology:

```
oc label dc/pam-kieserver app.openshift.io/runtime=processserver
oc label dc/pam-rhpamcentr app.openshift.io/runtime=processserver
```

Admin user is ```rhpamadmin```

To deploy the showcase application:

Edit code:

change web.xml to comment out old login-conf and replace it with:

    <login-config>
        <auth-method>KEYCLOAK</auth-method>
        <realm-name>pam</realm-name>
    </login-config>

Change jboss-web.xml security domain to keycloak from other



```
oc policy add-role-to-user view system:serviceaccount:$(oc project -q):default -n $(oc project -q)

oc new-build --image-stream=openshift/jboss-eap72-openshift:1.1 --binary=true --name=showcase
oc start-build showcase --from-file=target/jbpm-wb-case-mgmt-showcase-7.33.1-SNAPSHOT-eap7.war
oc new-app showcase

Modify route to set tls to edge termination, i.e.

tls:
  termination: edge

Also annotate the route to fix SSE timeout issues:

oc annotate route showcase --overwrite haproxy.router.openshift.io/timeout=1h


oc set env dc showcase JAVA_OPTS_APPEND="-Dorg.kie.server.location=https://pam-kieserver-pam.apps.cluster.ocplab.com/services/rest/server"
oc set env dc showcase SSO_URL=https://secure-sso-sso.apps.cluster.ocplab.com/auth SSO_REALM=pam SSO_USERNAME=admin SSO_PASSWORD=openshift SSO_CLIENT=showcase SSO_SECRET=f22af19d-bdae-421b-80b2-dc43e9e4e64f

```
