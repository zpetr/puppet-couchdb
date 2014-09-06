define couchdb::instance (
	$ref			= $name,
	$version		= 'stable',
	$dir			= '/usr/local/couchdb',
	$ref2dir		= true,
	$start_on_boot	= true,
	
	# HTTPD
	$bind			= '0.0.0.0',
	$port			= '5984',
	$www_auth		= false,
	
	#HTTPD AUTH
	$admin_login	= 'admin',
	$admin_password	= 'admin',
	
	# CORS
	$cors			= false,
	$cors_origins	= '*',
	$cors_headers	= 'Access-Control-Allow-Headers,Content-Type,Authorization,Content-Length,X-Requested-With'
){
	Exec["couchdb-${ref}"] -> Couchdb::Ini <| |> -> Service["couchdb-service-${ref}"]
	
	$couchdb_user = $::couchdb::manage_user ? {
		true	=> $::couchdb::user,
		false	=> 'root'
	}
	
	$couchdb_group = $::couchdb::manage_group ? {
		true	=> $::couchdb::group,
		false	=> $::couchdb::params::root_group
	}
	
	$install_dir = $ref2dir ? {
		true	=> "${dir}/${ref}",
		false	=> $dir
	}
	
	case $version {
		'stable','latest','last': {
			$git_option = ''
			#$install_tag_dir = 'stable'
		}
		'unstable','trunk','dev': {
			$git_option = "git=\"${::couchdb::params::couchdb_git} trunk\""
			#$install_tag_dir = 'trunk'
		}
		/(\d).(\d).(\d)/: {
			$git_option = "git=\"${::couchdb::params::couchdb_git} tags/${version}\""
			#$install_tag_dir = $version
		}
		/(\d).(\d)/: {
			$git_option = "git=\"${::couchdb::params::couchdb_git} tags/${version}.0\""
			#$install_tag_dir = "${version}.0"
		}
		default: {
			fail("Couchdb::Instance[${ref}]: version ${version} is not a correct version number")
		}
	}
	
	if !defined(File[$dir]) {
		file { $dir:
			ensure	=> directory,
		}
	}
	#if !defined(File["${couchdb::couchdb_src_dir}/dependencies/${install_tag_dir}"]) {
	#	file { "${couchdb::couchdb_src_dir}/dependencies/${install_tag_dir}":
	#		ensure	=> directory,
	#	}
	#}
	if !defined(File[$install_dir]) {
		file { $install_dir:
			ensure	=> directory,
			owner   => $couchdb_user,
			group   => $couchdb_group,
			mode    => '0755',
			recurse	=> true,
			require => User['couchdb'],
		}
	}

	exec { "couchdb-${ref}":
		cwd         => "${couchdb::couchdb_src_dir}/build-couchdb",
		environment => "HOME=${::root_home}",
		command		=> "rake ${git_option} install=${couchdb::couchdb_src_dir}/dependencies couchdb_build=${install_dir}" ,
		timeout		=> 1800,
		provider	=> 'shell',
		require		=> Class['couchdb'],
		notify		=> File[$install_dir],
	}		
	file { "${install_dir}/etc/couchdb/local.ini":
		ensure		=> file,
		require		=> [Exec["couchdb-${ref}"],User['couchdb']],
		owner   	=> $couchdb_user,
		group   	=> $couchdb_group,
		mode    	=> '0755',
    }
	file { "${install_dir}/etc/default/couchdb":
		ensure		=> file,
		require		=> Exec["couchdb-${ref}"],
    }
	$has_eth1 = ($::ipaddress_eth1 != '')
	$ip = $has_eth1 ? {
		true	=> $::ipaddress_eth1,
		false	=> $::ipaddress
	}
	$servicename = "couchdb-${ip}_${port}"
	#file { "${install_dir}/etc/init.d/${servicename}":
	#	ensure  => link,
	#	target  => "${install_dir}/etc/init.d/couchdb",
	#	require	=> [Exec["couchdb-${ref}"],File["${install_dir}/etc/couchdb/local.ini"]],
	#}
	file_line { $servicename:
		path	=> "${install_dir}/etc/init.d/couchdb",
		line	=> "# Provides:          ${servicename}",
		match	=> '^# Provides:',
		require	=> [Exec["couchdb-${ref}"],File["${install_dir}/etc/couchdb/local.ini"]],
		before	=> File["/etc/init.d/${servicename}"]
	}
	file { "/etc/init.d/${servicename}":
		ensure  => link,
		target  => "${install_dir}/etc/init.d/couchdb",
		require	=> [Exec["couchdb-${ref}"],File["${install_dir}/etc/couchdb/local.ini"]],
	}
	ini_setting { "${ref}-check_couchdb_user":
		ensure	=> present,
		path	=> "${install_dir}/etc/default/couchdb",
		section	=> "",
		setting	=> "COUCHDB_USER",
		value	=> $couchdb_user,
		require	=> [Exec["couchdb-${ref}"],File["${install_dir}/etc/default/couchdb"]],
		before	=> Service["couchdb-service-${ref}"],
	}
	service { "couchdb-service-${ref}":
		name		=> $servicename,
		ensure		=> 'running',
		enable		=> $start_on_boot,
		hasrestart	=> true,
		require		=> [
			Exec["couchdb-${ref}"],
			File["${install_dir}/etc/couchdb/local.ini"],
			File["/etc/init.d/${servicename}"]
		],
		subscribe	=> File["${install_dir}/etc/couchdb/local.ini"],
	}
	
	couchdb::ini { "local.ini-${ref}-${version}-bind":
		dir			=> $install_dir,	
		setting		=> 'bind_address',
		value		=> $bind,
	}
	
	couchdb::ini { "local.ini-${ref}-${version}-port":
		dir			=> $install_dir,
		instance	=> $ref,	
		setting		=> 'port',
		value		=> $port,
	}
	
	if str2bool($www_auth) {	
		couchdb::ini { "local.ini-${ref}-${version}-www_auth":
			dir			=> $install_dir,
			instance	=> $ref,
			setting		=> 'WWW-Authenticate',
			value		=> 'Basic realm="administrator"',
		}
		
		couchdb::ini { "local.ini-${ref}-${version}-require_valid_user":
			dir			=> $install_dir,
			instance	=> $ref,
			section		=> 'couch_httpd_auth',
			setting		=> 'require_valid_user',
			value		=> 'true',
		}
		
		couchdb::ini { "local.ini-${ref}-${version}-admin":
			dir			=> $install_dir,
			instance	=> $ref,
			section		=> 'admins',
			setting		=> $admin_login,
			value		=> $admin_password,
			notify		=> Service["couchdb-service-${ref}"],
		}
	}
	
	if str2bool($cors){
		couchdb::ini { "local.ini-${ref}-${version}-cors":
			dir			=> $install_dir,
			instance	=> $ref,
			setting		=> 'enable_cors',
			value		=> 'true',
		}
		
		couchdb::ini { "local.ini-${ref}-${version}-cors_origins":
			dir			=> $install_dir,
			instance	=> $ref,
			section		=> 'cors',
			setting		=> 'origins',
			value		=> $cors_origins,
		}
		
		couchdb::ini { "local.ini-${ref}-${version}-cors_headers":
			dir			=> $install_dir,
			instance	=> $ref,
			section		=> 'cors',
			setting		=> 'headers',
			value		=> $cors_headers,
		}
	}
}