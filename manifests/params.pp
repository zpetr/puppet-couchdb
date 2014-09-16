class couchdb::params {
  if($::fqdn) {
    $servername = $::fqdn
  } else {
    $servername = $::hostname
  }
  
  $src_dir	= '/usr/local/src/couchdb'
  $git_rep			= '-b ssl-ec git://github.com/zpetr/build-couchdb.git'
  $git_rep_recursive = false
  $couchdb_git		= 'git://git.apache.org/couchdb.git'

  if $::osfamily == 'RedHat' or $::operatingsystem == 'amazon' {
    $user                 = 'couchdb'
    $group                = 'couchdb'
    $root_group           = 'root'
	$updater		  	  = 'yum'
	$updater_options	  = '-y'
	$service_dir		  = 'rc.d'
    $packages = [
				'git',
				'gcc',
				'gcc-c++',
				'make',
				'libtool',
				'zlib-devel',
				'openssl-devel',
				'rubygem-rake',
				'ruby-rdoc',
				'help2man',
				'texinfo'
			]
	$otp_options = "erl_checkout=\"tags/OTP-17.1\""
	if $::operatingsystemmajrelease > 5 {
		$otp_compability_options = "erl_checkout=\"tags/OTP_R14B04\" erl_cflags=\"-DOPENSSL_NO_EC=1\""
	} else {
		$otp_compability_options = "erl_checkout=\"tags/OTP_R14B04\""
	}
  } elsif $::osfamily == 'Debian' {
    $user                 = 'couchdb'
    $group                = 'couchdb'
    $root_group           = 'root'
	$updater		  	  = 'apt-get'
	$updater_options	  = ''
	$service_dir		  = 'init.d'
    $packages = [
				'git',
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
	$otp_options = ""
	$otp_compability_options = "erl_checkout=\"tags/OTP_R14B04\""	
  } else {
    fail("Class['couchdb::params']: Unsupported osfamily: ${::osfamily}")
  }
}