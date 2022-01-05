#!/bin/bash
IFS='/'
read -a strarr <<< "$1"

#Print the splitted words
GIT_OWNER="$(echo ${strarr[0]} | tr '[:upper:]' '[:lower:]' | tr -c '[:alnum:]\n' '-')"
GIT_REPO="$(echo ${strarr[1]} | tr '[:upper:]' '[:lower:]' | tr -c '[:alnum:]\n' '-')"

cat << "EOF" > vals.yaml
ingress:
  enabled: false
service:
  type: NodePort
  nodePort: placeholderport
persistence:
  enabled: true
  storageClass: nfs
  size: 10Gi

# securityContext:
#   runAsUser: 1000

image:
  repository: git_owner/bioconductor_docker
  tag: git_repo

extraEnv:
  - name: "DISABLE_AUTH"
    value: "true"

# extraVolumes:
# - name: rstudio-conf
#   configMap:
#     name: rstudio-conf
# extraVolumeMounts:
# - name: rstudio-conf
#   mountPath: /etc/rstudio/rserver.conf
#   subPath: rserver.conf
EOF

sed -i "s/git_owner/$GIT_OWNER/g" vals.yaml
sed -i "s/git_repo/$GIT_REPO/g" vals.yaml

RANDOM_PORT=$((32000 + $RANDOM % 2000))

while [ ! -z $(kubectl get service --all-namespaces | grep $RANDOM_PORT) ]
do
    RANDOM_PORT=$((32000 + $RANDOM % 2000))
done

sed -i "s/placeholderport/$RANDOM_PORT/g" vals.yaml

helm repo add cloudve https://github.com/almahmoud/helm-charts/raw/bioc

helm upgrade --create-namespace --install -n "bioc-$GIT_REPO-$GIT_OWNER" rstudio cloudve/rstudio -f vals.yaml > rstudioinstalloutput

kubectl get -n "bioc-$GIT_REPO-$GIT_OWNER" -o jsonpath="{.spec.ports[0].nodePort}" services rstudio > nodeport
