# @summary
#   Installation initializing.
#
# @example CouchDB initializing
#    include couchdb
#
# @param manage_user
#   Create couchdb user.
# @param manage_group
#   Create couchdb group.
# @param user
#   User name.
# @param group
#   Group name.
# @param couchdb_src_dir
#   CouchDB source dir.
#
class couchdb (
    $manage_user        = true,
    $manage_group       = true,
    $user               = $::couchdb::params::user,
    $group              = $::couchdb::params::group,
    $couchdb_src_dir    = $::couchdb::params::src_dir
) inherits ::couchdb::params{
    Class['couchdb'] -> Couchdb::Instance <| |> -> Couchdb::Db <| |>
    if !defined(Package['curl']) {
        package { 'curl':
            ensure => installed,
        }
    }
    exec { 'packager-update':
        command => "/usr/bin/${::couchdb::params::updater} update ${::couchdb::params::updater_options}",
        timeout => '1200'
    }
    Exec['packager-update'] -> Package[$::couchdb::params::packages] -> Exec['clone']
    $::couchdb::params::packages.each |String $pkg|{
        if !defined(Package[$pkg]) {
            package { $pkg: ensure => 'installed' }
        }
    }
    $couchdb_group = $manage_group ? {
        true  => $group,
        false => $::couchdb::params::root_group
    }
    group { $group:
        ensure  => present,
    }
    $couchdb_user = $manage_user ? {
        true  => $user,
        false => 'root'
    }
    user { 'couchdb':
        ensure => present,
        name   => $couchdb_user,
        gid    => $couchdb_group ,
    }
    file { [$couchdb_src_dir,"${couchdb_src_dir}/dependencies"]:
        ensure => 'directory',
    }
    $recursive_string = str2bool($::couchdb::params::git_rep_recursive) ? {
        true  => '--recursive',
        false => ''
    }
    exec { 'clone':
        cwd         => $couchdb_src_dir,
        environment => "HOME=${::root_home}",
        command     => "/usr/bin/git clone ${recursive_string} ${::couchdb::params::git_rep}",
        timeout     => '600',
        creates     => "${couchdb_src_dir}/build-couchdb",
    }
    if $recursive_string == '' {
        exec { 'submodule init':
            cwd         => "${couchdb_src_dir}/build-couchdb",
            environment => "HOME=${::root_home}",
            command     => '/usr/bin/git submodule init',
            timeout     => '300',
            require     => Exec['clone'],
        }
        exec { 'submodule update':
            cwd         => "${couchdb_src_dir}/build-couchdb",
            environment => "HOME=${::root_home}",
            command     => '/usr/bin/git submodule update',
            timeout     => '900',
            tries       => 3,
            try_sleep   => 5,
            require     => [Exec['clone'],Exec['submodule init']]
        }
    }
}