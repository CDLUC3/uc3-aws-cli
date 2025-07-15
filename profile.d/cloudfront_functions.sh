# AWS CloudFront Query Functions

cf-dist-list () {
  $AWSBIN cloudfront list-distributions | yq -r '.DistributionList.Items[].AliasICPRecordals[].CNAME'
}


