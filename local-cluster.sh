#!/bin/bash

#echo "Cleaning up old kind k8s cluster"
#kind delete clusters kind

echo "Creating Kind local k8s cluster, if a kind cluster already exists the error is ok"
kind create cluster --config local-kind-cluster-non-HA.yaml

kubectl config use-context kind-kind

echo "Now since the local cluster is up i'd reccomend to start k9s around now to see what is being deployed, just run 'k9s' in a seperate terminal"
echo "And press 0 to see all pods (if it opens in pod view by default :pod if not)"

echo "Pushing Argo"
helm upgrade --install argo-cd argo/argo-cd --version 4.5.0 -n argocd --create-namespace --wait

echo "Pushing repo creds and app definition to ArgoCD"
kubectl apply -f repo-and-app.yaml

echo "Access argo via the kubectl port-forward command outputed by helm installation above"
echo ""
echo "kubectl port-forward service/argo-cd-argocd-server -n argocd 8080:443"
echo "Username Admin and password is"
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d