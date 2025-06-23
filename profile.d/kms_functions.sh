# AWS KMS functions

kms-alias-list () {
  $AWSBIN kms list-aliases | yq -r '.Aliases[].AliasName'
}

kms-key-show () {
  KEYID=$1
  $AWSBIN kms describe-key --key-id $KEYID
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

