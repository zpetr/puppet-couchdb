define couchdb::ini (
	$ininame	= $name,
	$dir,
	$instance	= '',
	$section	= 'httpd',
	$setting	= '',
	$value		= '',
){
	
	ini_setting { $name:
		ensure  => present,
		path    => "${dir}/etc/couchdb/local.ini",
		section => $section,
		setting => $setting,
		value   => $value,
	}
}