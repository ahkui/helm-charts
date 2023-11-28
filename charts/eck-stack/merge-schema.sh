#!/bin/bash

which yq >/dev/null 2>&1 || (echo "missing 'yq'. please install from https://github.com/mikefarah/yq" && exit 1)

BASEDIR=$(dirname "$0")

$BASEDIR/charts/eck-elasticsearch/download-schema.sh &
$BASEDIR/charts/eck-kibana/download-schema.sh &
wait

yq eval-all -I 4 -o json --inplace '
    select(fileIndex==0).properties.eck-elasticsearch = select(fileIndex==1)
    | select(fileIndex==0).definitions = select(fileIndex==0).definitions * select(fileIndex==1).definitions
    | select(fileIndex==0).properties.eck-elasticsearch.required = []
    | select(fileIndex==0).properties.eck-elasticsearch.properties.spec.required = []
    | select(fileIndex==0)
' $BASEDIR/values.schema.json $BASEDIR/charts/eck-elasticsearch/values.schema.json

yq eval-all -I 4 -o json --inplace '
    select(fileIndex==0).properties.eck-kibana = select(fileIndex==1)
    | select(fileIndex==0).definitions = select(fileIndex==0).definitions * select(fileIndex==1).definitions
    | select(fileIndex==0).properties.eck-kibana.required = []
    | select(fileIndex==0).properties.eck-kibana.properties.spec.required = []
    | select(fileIndex==0)
' $BASEDIR/values.schema.json $BASEDIR/charts/eck-kibana/values.schema.json
