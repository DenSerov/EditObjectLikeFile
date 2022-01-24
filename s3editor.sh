#!/bin/bash
ENDPOINT=https://dc1-g1:8082
EDITOR=$1
BUCKET=$2
OBJECT=$3

echo
if [[ "$#" -ne 3 ]]; then
   echo "$#" parameters.;
   echo "Usage help: s3edit [editor|viewer] bucket object."
   exit
fi
echo Opening object \"$OBJECT\" from S3 bucket \"$BUCKET\". ;
aws s3api get-object-tagging --bucket=$BUCKET --key=$OBJECT --endpoint-url $ENDPOINT --no-verify-ssl --output yaml 2>/dev/null > $OBJECT.tags
echo
echo Changing tags for \"$OBJECT\" object  with \"$EDITOR\" editor/viewer. ; $EDITOR $OBJECT.tags

echo
echo Saving object \"$OBJECT\" tags in S3 bucket \"$BUCKET\".
echo Bucket: $BUCKET > input.yaml
echo Key: $OBJECT >> input.yaml
echo Tagging: >> input.yaml
awk '{print " " $0}' $OBJECT.tags >> input.yaml

aws s3api put-object-tagging --endpoint-url $ENDPOINT --no-verify-ssl --cli-input-yaml file://input.yaml 2>/dev/null
echo
echo Cleaning local temp data. ; rm -f $OBJECT.tags
echo Done!
echo
