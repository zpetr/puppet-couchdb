# @summary
#   Ini settings.
#
# @example CouchDB ini setting
#    couchdb::ini { "local.ini-bind":
#        dir     => $install_dir,	
#        setting => 'bind_address',
#        value   => '0.0.0.0',
#    }
#
# @param dir
#   CouchDB directory.
# @param ininame
#   Name.
# @param instance
#   Instance name.
# @param section
#   Section name.
# @param setting
#   Setting name.
# @param value
#   Value.
#
define couchdb::ini (
    $dir,
    $ininame  = $name,
    $instance = '',
    $section  = 'httpd',
    $setting  = '',
    $value    = '',
){
    ini_setting { $name:
        ensure  => present,
        path    => "${dir}/etc/couchdb/local.ini",
        section => $section,
        setting => $setting,
        value   => $value,
    }
}