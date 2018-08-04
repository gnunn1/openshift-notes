Add permissions to default service account to enable containers with any uuid (i.e. root, etc)
```
oc project <project-name>
oc adm policy add-scc-to-user anyuid -z useroot
```
