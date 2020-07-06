Utility scripts for accessing AWS Client resources from UC3 servers.

## Dependencies

- ENV
  - SSM_ROOT_PATH
  - SSM_DB_NAME (for servers with mysql)
  - SSM_DB_ROLE (defaults to readonly)
- jq installed on the machine
- ssm get-parameters-by-path access


## aws cli aliases

Copy the alias file into your personal aws configs:

mkdir -p ~/.aws/cli
git clone https://github.com/CDLUC3/uc3-aws-cli.git
cp uc3-aws-cli/alias ~/.aws/cli/alias
