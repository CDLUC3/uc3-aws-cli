# CodeArtifact shell fuctions
#

codeart-domain-list() {
  $AWSBIN codeartifact list-domains | yq -r .domains[].name
}

codeart-domain-show() {
  DOMAIN_NAME=$1
  $AWSBIN codeartifact describe-domain --domain $DOMAIN_NAME
}

# The rest of these functions all assume a single domain
codeart-repo-list() {
  DOMAIN_NAME=$(codeart-domain-list)
  $AWSBIN codeartifact list-repositories-in-domain --domain $DOMAIN_NAME | yq -r .repositories[].name
}

codeart-repo-show() {
  DOMAIN_NAME=$(codeart-domain-list)
  REPO_NAME=$1
  $AWSBIN codeartifact describe-repository --domain $DOMAIN_NAME --repository $REPO_NAME
}

codeart-package-list() {
  DOMAIN_NAME=$(codeart-domain-list)
  REPO_NAME=$1
  $AWSBIN codeartifact list-packages --domain $DOMAIN_NAME --repository $REPO_NAME |yq -r .packages[].package
}

codeart-package-show() {
  DOMAIN_NAME=$(codeart-domain-list)
  REPO_NAME=$1
  PACKAGE_NAME=$2
  $AWSBIN codeartifact list-packages --domain $DOMAIN_NAME --repository $REPO_NAME |yq -ry ".packages[] | select(.package == \"$PACKAGE_NAME\")"
}

codeart-package-show-format() {
  REPO_NAME=$1
  PACKAGE_NAME=$2
  codeart-package-show $REPO_NAME $PACKAGE_NAME | yq -r .format
}

codeart-package-list-versions() {
  DOMAIN_NAME=$(codeart-domain-list)
  REPO_NAME=$1
  PACKAGE_NAME=$2
  PACKAGE_DESC=$(codeart-package-show $REPO_NAME $PACKAGE_NAME)
  FORMAT=$(echo "$PACKAGE_DESC" | yq -r .format)
  NAMESPACE=$(echo "$PACKAGE_DESC" | yq -r .namespace)
  $AWSBIN codeartifact list-package-versions --domain $DOMAIN_NAME --repository $REPO_NAME --package $PACKAGE_NAME --format $FORMAT --namespace $NAMESPACE | yq -r .versions[].version
}




# aws codeartifact list-package-versions --domain cdlib-uc3-mrt --repository uc3-mrt-java --package mrt-invwar --format maven --namespace org.cdlib.mrt
# aws codeartifact describe-package-version --domain cdlib-uc3-mrt --repository uc3-mrt-java --package mrt-invwar --format maven --namespace org.cdlib.mrt --package-version 3.0-20240816.212446-15
# {
#     "packageVersion": {
#         "format": "maven",
#         "namespace": "org.cdlib.mrt",
#         "packageName": "mrt-invwar",
#         "displayName": "UC3-mrtInventoryWar",
#         "version": "3.0-20240816.212446-15",
#         "homePage": "http://uc3.cdlib.org",
#         "sourceCodeRepository": "http://uc3.cdlib.org",
#         "publishedTime": "2024-08-16T14:24:50.560000-07:00",
#         "licenses": [],
#         "revision": "rxQLdX+jVLe/8DAgAHJPa1oQFW6kCWwS2pyEF3z2UnA=",
#         "status": "Unlisted",
#         "origin": {
#             "domainEntryPoint": {
#                 "repositoryName": "uc3-mrt-java"
#             },
#             "originType": "INTERNAL"
#         }
#     }
# }

