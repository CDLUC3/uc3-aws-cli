Utility scripts for accessing AWS Client resources from UC3 servers.

## Dependencies

- ENV
  - SSM_ROOT_PATH
  - SSM_DB_NAME (for servers with mysql)
  - SSM_DB_ROLE (defaults to readonly)
- jq installed on the machine
- ssm get-parameters-by-path access
