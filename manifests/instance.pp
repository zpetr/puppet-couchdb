# @summary
#   Install CouchDB instance.
#
# @example CouchDB installation
#    couchdb::instance { "main": }
#
# @param ref
#   Instance name.
# @param version
#   Version to install. Default: stable
# @param dir
#   Install to directory. Default: /usr/local/couchdb
# @param ref2dir
#   Create subdirectory with instance name. Default: true
# @param start_on_boot
#   Start CouchDB instance on boot. Default: true
# @param bind
#   Bin IP. Default: 0.0.0.0
# @param port
#   Port. Default: 5984
# @param www_auth
#   Require authentification. Default: false
# @param admin_login
#   Admin user. Default: admin
# @param admin_password
#   Admin password. Default: admin
# @param cors
#   Enable CORS. Default: false
# @param cors_origins
#   Allowed CORS origins. Default: *
# @param cors_headers
#   Allowed CORS headers. Default: Access-Control-Allow-Headers,Content-Type,Authorization,Content-Length,X-Requested-With
#
define couchdb::instance (
    $ref            = $name,
    $version        = 'stable',
    $dir            = '/usr/local/couchdb',
    $ref2dir        = true,
    $start_on_boot  = true,
    # HTTPD
    $bind           = '0.0.0.0',
    $port           = '5984',
    $www_auth       = false,

    #HTTPD AUTH
    $admin_login    = 'admin',
    $admin_password = 'admin',

    # CORS
    $cors           = false,
    $cors_origins   = '*',
    $cors_headers   = 'Access-Control-Allow-Headers,Content-Type,Authorization,Content-Length,X-Requested-With'
){
    Exec["couchdb-${ref}"] -> Couchdb::Ini <| |> -> Service["couchdb-service-${ref}"]

    $couchdb_user = $::couchdb::manage_user ? {
        true    => $::couchdb::user,
        false    => 'root'
    }

    $couchdb_group = $::couchdb::manage_group ? {
        true  => $::couchdb::group,
        false => $::couchdb::params::root_group
    }

    $install_dir = $ref2dir ? {
        true  => "${dir}/${ref}",
        false => $dir
    }

    case $version {
        'stable','latest','last': {
            $git_option = ''
        }
        'unstable','trunk','dev': {
            $git_option = "git=\"${::couchdb::params::couchdb_git} trunk\""
        }
        /(\d).(\d).(\d)/: {
            $git_option = "git=\"${::couchdb::params::couchdb_git} tags/${version}\""
        }
        /(\d).(\d)/: {
            $git_option = "git=\"${::couchdb::params::couchdb_git} tags/${version}.0\""
        }
        default: {
            fail("Couchdb::Instance[${ref}]: version ${version} is not a correct version number")
        }
    }

    if type_of($version) == 'String' {
        $otp_options = $::couchdb::params::otp_options
    } elsif $version < '1.2' {
        fail("Couchdb::Instance[${ref}]: ${version} version support is not provided by this module. Min available: 1.2")
    } elsif $version < '1.4' {
        $otp_options = $::couchdb::params::otp_compability_options
    } elsif $version =~ /(stable|latest|last|unstable|trunk|dev)/ {
        $otp_options = $::couchdb::params::otp_options
    } elsif $version > '1.7.1' {
        fail("Couchdb::Instance[${ref}]: version ${version} of CouchDB is not supported by this version of module. Max available: 1.7.1")
    } else {
        $otp_options = $::couchdb::params::otp_options
    }

    if !defined(File[$dir]) {
        file { $dir:
            ensure    => directory,
        }
    }

    if !defined(File[$install_dir]) {
        file { $install_dir:
            ensure  => directory,
            owner   => $couchdb_user,
            group   => $couchdb_group,
            mode    => '0755',
            recurse => true,
            require => User['couchdb'],
        }
    }

    exec { "couchdb-${ref}":
        cwd         => "${couchdb::couchdb_src_dir}/build-couchdb",
        environment => "HOME=${::root_home}",
        command     => "rake ${git_option} ${otp_options} install=${couchdb::couchdb_src_dir}/dependencies couchdb_build=${install_dir}" ,
        timeout     => 1800,
        provider    => 'shell',
        require     => Class['couchdb'],
        notify      => File[$install_dir],
    }
    file { "${install_dir}/etc/couchdb/local.ini":
        ensure  => file,
        require => [Exec["couchdb-${ref}"],User['couchdb']],
        owner   => $couchdb_user,
        group   => $couchdb_group,
        mode    => '0755',
    }
    file { "${install_dir}/etc/default/couchdb":
        ensure  => file,
        require => Exec["couchdb-${ref}"],
    }
    $has_eth1 = ($::ipaddress_eth1 != '')
    $ip = $has_eth1 ? {
        true  => $::ipaddress_eth1,
        false => $::ipaddress
    }
    $servicename = "couchdb-${ip}_${port}"
    file_line { $servicename:
        path    => "${install_dir}/etc/${::couchdb::params::service_dir}/couchdb",
        line    => "# Provides:          ${servicename}",
        match   => '^# Provides:',
        require => [Exec["couchdb-${ref}"],File["${install_dir}/etc/couchdb/local.ini"]],
        before  => File["/etc/init.d/${servicename}"]
    }
    file { "/etc/init.d/${servicename}":
        ensure  => link,
        target  => "${install_dir}/etc/${::couchdb::params::service_dir}/couchdb",
        require => [Exec["couchdb-${ref}"],File["${install_dir}/etc/couchdb/local.ini"]],
    }
    ini_setting { "${ref}-check_couchdb_user":
        ensure  => present,
        path    => "${install_dir}/etc/default/couchdb",
        section => '',
        setting => 'COUCHDB_USER',
        value   => $couchdb_user,
        require => [Exec["couchdb-${ref}"],File["${install_dir}/etc/default/couchdb"]],
        before  => Service["couchdb-service-${ref}"],
    }
    service { "couchdb-service-${ref}":
        ensure     => 'running',
        name       => $servicename,
        enable     => $start_on_boot,
        hasrestart => true,
        require    => [
            Exec["couchdb-${ref}"],
            File["${install_dir}/etc/couchdb/local.ini"],
            File["/etc/init.d/${servicename}"]
        ],
        subscribe  => File["${install_dir}/etc/couchdb/local.ini"],
    }

    couchdb::ini { "local.ini-${ref}-${version}-bind":
        dir     => $install_dir,
        setting => 'bind_address',
        value   => $bind,
    }

    couchdb::ini { "local.ini-${ref}-${version}-port":
        dir      => $install_dir,
        instance => $ref,
        setting  => 'port',
        value    => $port,
    }

    if str2bool($www_auth) {
        couchdb::ini { "local.ini-${ref}-${version}-www_auth":
            dir      => $install_dir,
            instance => $ref,
            setting  => 'WWW-Authenticate',
            value    => 'Basic realm="administrator"',
        }

        couchdb::ini { "local.ini-${ref}-${version}-require_valid_user":
            dir      => $install_dir,
            instance => $ref,
            section  => 'couch_httpd_auth',
            setting  => 'require_valid_user',
            value    => true,
        }

        couchdb::ini { "local.ini-${ref}-${version}-admin":
            dir      => $install_dir,
            instance => $ref,
            section  => 'admins',
            setting  => $admin_login,
            value    => $admin_password,
            notify   => Service["couchdb-service-${ref}"],
        }
    }

    if str2bool($cors){
        couchdb::ini { "local.ini-${ref}-${version}-cors":
            dir      => $install_dir,
            instance => $ref,
            setting  => 'enable_cors',
            value    => true,
        }

        couchdb::ini { "local.ini-${ref}-${version}-cors_origins":
            dir      => $install_dir,
            instance => $ref,
            section  => 'cors',
            setting  => 'origins',
            value    => $cors_origins,
        }

        couchdb::ini { "local.ini-${ref}-${version}-cors_headers":
            dir      => $install_dir,
            instance => $ref,
            section  => 'cors',
            setting  => 'headers',
            value    => $cors_headers,
        }
    }
}