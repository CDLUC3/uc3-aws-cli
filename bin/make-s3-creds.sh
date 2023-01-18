#!/bin/bash


EXIT_ON_DIE=true
source ~/.profile.d/uc3-aws-util.sh

create_ssm_path_from_tags
check_ssm_root

AK_SDSC=`get_ssm_value_by_name cloud/nodes/sdsc-accessKey`
SK_SDSC=`get_ssm_value_by_name cloud/nodes/sdsc-secretKey`
AK_WAS=`get_ssm_value_by_name cloud/nodes/wasabi-accessKey`
SK_WAS=`get_ssm_value_by_name cloud/nodes/wasabi-secretKey`

cat << HERE > ~/.aws/credentials
[sdsc]
aws_access_key_id = ${AK_SDSC}
aws_secret_access_key = ${SK_SDSC}

[wasabi]
aws_access_key_id = ${AK_WAS}
aws_secret_access_key = ${SK_WAS}
HERE

chmod 400 ~/.aws/credentials

cat << HERE

https://github.com/CDLUC3/mrt-cloud/blob/main/cloud-conf/src/main/resources/yaml/cloudConfig.yml

** Stage **

aws s3 ls uc3-s3mrt5001-stg/
aws s3 ls uc3-s3mrt6001-stg/
aws s3 ls uc3-s3mrt1001-stg/
aws s3 ls dryad-assetstore-merritt-stage/
aws s3 ls dryad-assetstore-merritt-stage-east/

aws s3 ls cdl.sdsc.stage/ --profile sdsc --endpoint https://cdl.s3.sdsc.edu:443
aws s3 ls uc3-wasabi-useast-2.stage/ --profile wasabi --endpoint https://s3.us-east-2.wasabisys.com:443

** Prod **

aws s3 ls uc3-s3mrt5001-prd/
aws s3 ls uc3-s3mrt6001-prd/
aws s3 ls uc3-s3mrt1001-prd/
aws s3 ls dryad-assetstore-merritt-west/
aws s3 ls dryad-assetstore-merritt-east/

aws s3 ls cdl.sdsc.prod/ --profile sdsc --endpoint https://cdl.s3.sdsc.edu:443
aws s3 ls uc3-wasabi-useast-2.prod/ --profile wasabi --endpoint https://s3.us-east-2.wasabisys.com:443
