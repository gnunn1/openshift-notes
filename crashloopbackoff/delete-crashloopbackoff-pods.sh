oc get pods --all-namespaces | grep CrashLoopBackOff | awk '{print $2 " --namespace=" $1}' | xargs oc delete pod
