See here for details:  https://blog.openshift.com/remotely-push-pull-container-images-openshift
```
docker login -u user03 -p <token> docker-registry-default.apps.ocplab.com
# Pull an example image
docker pull jimleitch/petclinic:2.0.0
# Tag image
docker tag jimleitch/petclinic:2.0.0 docker-registry-default.apps.ocplab.com/petclinic/petclinic:latest
# Push image
docker push docker-registry-default.apps.ocplab.com/petclinic/petclinic:latest
# Create application
oc new-app petclinic
```
