class couchdb::params {
  if($::fqdn) {
    $servername = $::fqdn
  } else {
    $servername = $::hostname
  }
  
  $src_dir	= '/usr/local/src/couchdb'
  $git_rep			= 'git://github.com/zpetr/build-couchdb.git'
  $git_rep_recursive = false
  $couchdb_git		= 'git://git.apache.org/couchdb.git'

  if $::osfamily == 'RedHat' or $::operatingsystem == 'amazon' {
    $user                 = 'couchdb'
    $group                = 'couchdb'
    $root_group           = 'root'
	$updater		  	  = 'yum'
    $packages = [
				'gcc',
				'gcc-c++',
				'make',
				'libtool',
				'zlib-devel',
				'openssl-devel',
				'rubygem-rake',
				'ruby-rdoc',
			]
  } elsif $::osfamily == 'Debian' {
    $user                 = 'couchdb'
    $group                = 'couchdb'
    $root_group           = 'root'
	$updater		  	  = 'apt-get'
    $packages = [
				'help2man',
				'make',
				'gcc',
				'zlib1g-dev',
				'libssl-dev',
				'rake',
				'texinfo',
				'flex',
				'dctrl-tools',
				'libsctp-dev',
				'libxslt1-dev',
				'libcap2-bin',
				'ed',
			]
  } else {
    fail("Class['couchdb::params']: Unsupported osfamily: ${::osfamily}")
  }
}