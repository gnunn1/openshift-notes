kill a pod with no grace period, useful when a pod refuses to terminate

```oc delete pod POD --force --grace-period=0```
