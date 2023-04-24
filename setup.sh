#!/bin/sh

#echo "Cleaning up old kind k8s cluster"
#kind delete clusters kind

ensure_context() {
  if ! kubectl config current-context = "kind-kind"; then
    echo "You are in the wrong context! Exiting"
    exit 1
  fi
}

echo "Creating Kind local k8s cluster"
kind create cluster --config local-kind-cluster-non-HA.yaml

kubectl config use-context kind-kind
ensure_context

echo "Now since the local cluster is up i'd reccomend to start k9s and navigate around to see what is being deployed, just run 'k9s' in a seperate terminal"
echo "And press 0 to see all namespaces at once (hopefully it opens in pod view by default, type ':pod' and press enter if not)"

echo "Deploying ArgoCD"
helm upgrade --install argo-cd argo/argo-cd --version 5.29.1 -n argocd --create-namespace --wait

echo "Pushing repo creds and argoApplication CRD's to argoCD"
kubectl apply -f repo-and-app.yaml

echo "\n\n\n"
echo "Access argoCD via kubectl port-forward command (in a new terminal) \n"
echo ">  kubectl port-forward service/argo-cd-argocd-server -n argocd 8080:443 < \n"
echo "Now open https://localhost:8080/ in a browser and accept the faulty certificate \n"
INITIALPASS=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath={.data.password} | base64 -d)
echo "Username is admin and password is: $INITIALPASS"
