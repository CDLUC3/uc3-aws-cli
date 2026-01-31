# AWS KMS functions

kms-alias-list () {
  $AWSBIN kms list-aliases | yq -r '.Aliases[].AliasName'
}

kms-alias-show-keyid () {
  ALIAS=$1
  $AWSBIN kms list-aliases | yq -r ".Aliases[] | select(.AliasName == \"$ALIAS\") | .TargetKeyId"
}

kms-key-show () {
  ALIAS=$1
  KEYID=$(kms-alias-show-keyid $ALIAS)
  $AWSBIN kms describe-key --key-id $KEYID
}

kms-key-policy-show () {
  ALIAS=$1
  KEYID=$(kms-alias-show-keyid $ALIAS)
  POLICY_NAMES=$($AWSBIN kms list-key-policies --key-id $KEYID | yq -r '.PolicyNames[]')
  for name in $POLICY_NAMES; do
      response=$(aws kms get-key-policy --key-id $KEYID --policy-name $name)
      #echo $response | yq -ry '.PolicyName'
      echo -n "PolicyName: "
      echo $response | jq -r '.PolicyName'
      echo $response | jq -r '.Policy' | json2yaml
  done
}

kms-key-list-ids () {
  $AWSBIN kms list-keys | yq -r '.Keys[].KeyId'
}

kms-alias-show-customer-managed () {
  for KEYID in $(kms-key-list-ids); do
    #echo $KEYID
    KEYMANAGER=$($AWSBIN kms describe-key --key-id $KEYID | yq -r '.KeyMetadata.KeyManager')
    if [ $KEYMANAGER == "CUSTOMER" ]; then
      #kms-key-show $KEYID
      $AWSBIN kms list-aliases --key-id $KEYID
    fi
  done
}

