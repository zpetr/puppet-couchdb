define couchdb::db (
	$dbname			= $name,
	$target			= 'http://127.0.0.1:5984',
	$source			= ''
){
	exec { "create db ${name}":
		command     => "curl -X PUT ${target}/${dbname}",
		provider	=> 'shell',
		unless		=> "curl --head --silent --fail --output /dev/null \"${target}/${dbname}\"",
	}
	
	if $source {
		exec { "couchdb replication to ${name}":
			command     => "curl -H 'Content-Type: application/json' -X POST ${target}/_replicate -d '{\"source\":\"${source}\",\"target\":\"${target}/${dbname}\"}'",
			provider	=> 'shell',
			timeout		=> 0,
			require		=> Exec["create db ${name}"],
		}
	}
}