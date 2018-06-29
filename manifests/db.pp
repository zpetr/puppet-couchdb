# @summary
#   Create a database.
#
# @example Create CouchDB database called database_test
#   couchdb::db { "database_test": }
#
# @param dbname
#   Database name.
# @param target
#   Instance target URL. If you protect instance by login/password, use URL in form: http(s)://login:password@URI:PORT. Default: http://127.0.0.1:5984
# @param source
#   Source URL where this database will be replecated from. Default: [empty]
#
define couchdb::db (
    $dbname = $name,
    $target = 'http://127.0.0.1:5984',
    $source = ''
){
    exec { "create db ${name}":
        command  => "curl --retry 5 --retry-delay 1 -X PUT ${target}/${dbname}",
        provider => 'shell',
        unless   => "curl --head --silent --fail --output /dev/null \"${target}/${dbname}\"",
    }
    if $source {
        exec { "couchdb replication to ${name}":
            command  => "curl -H 'Content-Type: application/json' -X POST ${target}/_replicate \
-d '{\"source\":\"${source}\",\"target\":\"${target}/${dbname}\"}'",
            provider => 'shell',
            timeout  => 0,
            require  => Exec["create db ${name}"],
        }
    }
}