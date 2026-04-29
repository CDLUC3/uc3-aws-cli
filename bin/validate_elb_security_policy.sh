#!/bin/bash
#
# List ELB Listener SslPolicy setting for each ELB in UC3 program accounts.

OUTDIR=$(mktemp -d)

PROFILES="
cdl-uc3-dev-ops
cdl-uc3-prd-ops
"

REGIONS="
us-west-2
"

for p in $PROFILES; do
  echo "Checking ELBs as profile $p:"
  for r in $REGIONS; do
    for LB in `aws --profile $p elbv2 describe-load-balancers | jq '.LoadBalancers[].LoadBalancerArn' | sed 's/\"//g'`; do
      aws --profile $p elbv2 describe-listeners --load-balancer-arn $LB | jq '.Listeners[] | select(.Protocol=="HTTPS") | "\(.SslPolicy) - \(.ListenerArn)"' >> $OUTDIR/$p.out
    done
  done
  cat $OUTDIR/$p.out
done
rm -rf $OUTDIR
