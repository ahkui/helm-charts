#!/bin/bash

which yq >/dev/null 2>&1 || (echo "missing 'yq'. please install from https://github.com/mikefarah/yq" && exit 1)

BASEDIR=$(dirname "$0")
CRDS_URL=https://raw.githubusercontent.com/elastic/cloud-on-k8s/main/config/crds/v1/bases/kibana.k8s.elastic.co_kibanas.yaml

curl -sS $CRDS_URL |
    yq '.spec.versions.[0].schema.openAPIV3Schema.properties.spec' -o json |
    yq eval-all -I 4 -o json --inplace \
        'select(fileIndex==0).properties.spec = select(fileIndex==1) | select(fileIndex==0)' \
        $BASEDIR/values.schema.json -
