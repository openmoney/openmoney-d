#!/bin/bash

: ${COUCHBASE_LO:=couchbase}
: ${COUCHBASE_ADMIN_USERNAME:=admin}
: ${COUCHBASE_ADMIN_PASSWORD:=asdfasdf}
: ${COUCHBASE_INIT_WAIT:=15}


main() {
    if [[ -z "$@" ]]; then
        [[ "$OM_ENV" == "dev" ]] && check_couchbase && init_couchbase
        exec npm run start
    else
        exec "$@"
    fi
}

check_couchbase() {
    for i in {1..60}; do
        local result="$(couchbase_api pools/default/buckets -w '%{http_code}')"
        [[ $result == "[]200" || $result == "401" ]] && printf "Openmoney couchbase buckets not found.\n" && return 0
        [[ ${result:${#result}-3} == '200' ]] && printf "Openmoney couchbase buckets found.\n" && return 1
        printf "Waiting for couchbase to initialize. ($i)\n"
        sleep 1
    done
    printf "\nUnable to connect to couchbase!  Is it running?\n"
    exit 1
}

init_couchbase() {
    printf 'Initializing couchbase.\n'
    couchbase_api settings/web \
        -d username=$COUCHBASE_ADMIN_USERNAME \
        -d password=$COUCHBASE_ADMIN_PASSWORD \
        -d port=SAME

    for name in default oauth2Server openmoney_global openmoney_stewards; do
        couchbase_init_bucket
    done
    # Installs seed data.  We need to wait or the buckets are not found.
    printf '\nGiving couchbase %s seconds to work itself out.\n' "$COUCHBASE_INIT_WAIT"
    sleep $COUCHBASE_INIT_WAIT
    npm run install:db
}

couchbase_init_bucket() {
    couchbase_api pools/default/buckets \
        -d flushEnabled=1 \
        -d replicaNumber=0 \
        -d evictionPolicy=fullEviction \
        -d ramQuotaMB=128 \
        -d bucketType=membase \
        -d name=$name
}

couchbase_api() {
    curl "http://$COUCHBASE_LO:8091/$1" -s \
        -u "$COUCHBASE_ADMIN_USERNAME:$COUCHBASE_ADMIN_PASSWORD" \
        "${@:2}"
}

main "$@"
