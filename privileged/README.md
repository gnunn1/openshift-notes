Add the privileged capability to the  default service account:

```
oc adm policy add-scc-to-user privileged -z default -n <project>
```
