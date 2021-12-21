#!/bin/bash
IFS='/'
read -a strarr <<< "$1"

#Print the splitted words
GIT_OWNER="$(echo ${strarr[0]} | tr -dc '[:alnum:]' | tr '[:upper:]' '[:lower:]')"
GIT_REPO="$(echo ${strarr[1]} | tr -dc '[:alnum:]' | tr '[:upper:]' '[:lower:]')"

cat << "EOF" > vals.yaml
ingress:
  enabled: true
  annotations:
    kubernetes.io/tls-acme: "true"
    cert-manager.io/cluster-issuer: letsencrypt-prod
    nginx.ingress.kubernetes.io/secure-backends: "true"
    nginx.ingress.kubernetes.io/rewrite-target: /$2
  hosts:
    - host: "example.bioconductor.149.165.157.111.nip.io"
      paths:
        - /placeholder/rstudio(/|$)(.*)
  tls:
     - secretName: "example-bioconductor-149-165-157-111-nip-io-key"
       hosts:
         - "example.bioconductor.149.165.157.111.nip.io"

persistence:
  enabled: true
  storageClass: nfs
  size: 10Gi

# securityContext:
#   runAsUser: 1000

image:
  repository: bioconductor/bioconductor_docker
  tag: RELEASE_3_10

extraVolumes:
- name: rstudio-conf
  configMap:
    name: rstudio-conf
extraVolumeMounts:
- name: rstudio-conf
  mountPath: /etc/rstudio/rserver.conf
  subPath: rserver.conf
EOF

sed -i "s/example/$GIT_OWNER/g" vals.yaml
sed -i "s/placeholder/$GIT_REPO/g" vals.yaml

helm repo add cloudve https://github.com/CloudVE/helm-charts/raw/master

helm upgrade --create-namespace --install -n osca-test-1 rstudio cloudve/rstudio -f vals.yaml > rstudioinstalloutput
