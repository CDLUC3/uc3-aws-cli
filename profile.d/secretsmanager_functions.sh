# secretsmanager utiltiy functions
#

secrets-list() {
    aws secretsmanager list-secrets | jq -r .SecretList[].Name
}

secrets-show() {
    aws secretsmanager describe-secret --secret-id $1
}

secrets-get() {
    aws secretsmanager get-secret-value --secret-id $1 | jq -r .SecretString
}

secrets-put() {
    response=$(secrets-show $1 2>&1 >/dev/null)
    if [ "$?" == 0 ]; then
        aws secretsmanager put-secret-value --secret-id $1 --secret-string $2
    else
        aws secretsmanager create-secret --name $1 --secret-string $2
    fi
}

secrets-delete() {
    aws secretsmanager delete-secret --name $1
}


