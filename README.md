# CouchDB
----------

## Table of Contents

1. [Overview](#overview)
2. [Module Description](#module-description)
3. [Usage](#usage)
    * [Preconfiguration](#preconfiguration)
    * [Install instance](#install-instance)
    * [Create database](#create-database)
4. [Examples](#examples)
5. [Reference](#reference)
6. [Limitations](#limitations)

##Overview

The couchdb module installs, configures, and manages the [CouchDB](http://couchdb.apache.org/ "CouchDB") instances on any CouchDB version of 1.x branch (2.x is not supported by this version) starting from *1.2.0* to *1.7.1* (version *1.6.2* is prefered and installed by default).

Installation is based on [jhs/build-couchdb](https://github.com/jhs/build-couchdb "build-couchdb") builder.

##Module Description

The CouchDB module manages both the installation and configuration of CouchDB.

You can lunch multiple instances of CouchDB on the same node, create databases and import data from remote source.

##Usage

###Preconfiguration
```puppet
include couchdb
```
###Install instance
```puppet
couchdb::instance { "instance-ref": }
```

###Create database
```puppet
couchdb::db { "database_name": }
```

##Examples

* Default installation of the latest version of CouchDB on port 5984
```puppet
include couchdb
couchdb::instance { "main": }
```

* Latest version of CouchDB on port 5985 with http authentication enabled
```puppet
include couchdb
couchdb::instance { "main":
	port			=> '5985',
	www_auth		=> true,
	admin_login		=> 'admin',
	admin_password	=> 'admin',
}
```

* Multiple versions
```puppet
include couchdb
couchdb::instance { "main": }
couchdb::instance { "test":
	version			=> '1.4.0'
	port			=> '5985',
}
```

* Install and create database
```puppet
include couchdb
couchdb::instance { "main": }
couchdb::db { "database_test": }
```
##Reference

###Classes

* `couchdb`: Download build scripts and verify dependencies.

###Defines
* `couchdb::instance`: Install one instance of CouchDB.
* `couchdb::db`: Create a database.

###Parameters

####couchdb

#####`manage_user`

Manage specific user for CouchDB instance. If *false* root is used.

- Value: boolean (true/false)
- Default: *true*

#####`manage_group`

Manage specific group for CouchDB instance. If *false* root group is used.

- Value: boolean (true/false)
- Default: *true*

#####`user`

Specific user name for CouchDB instance. Used if manage_user = true.

- Default: *couchdb*

#####`group`

Specific group name for CouchDB instance. Used if manage_group = true.

- Default: *couchdb*

#####`couchdb_src_dir`

Folder where CouchDB source code will be downloaded.

- Default: */usr/local/src/couchdb*

####couchdb::instance

#####`ref`

Unique name of CouchDB instance.

#####`version`

Version of CouchDB to install (starting from 1.2.0)

- Value
    * *stable* / *latest* / *last* - Latest version
    * *unstable* / *trunk* / *dev* - Current trunk version
    * \*.\* - Install version: \*.*.0. Example: 1.5 
    * \*.\*.\* - Version to install. Example: 1.4.0
- Default: *stable*

#####`dir`

Directory for the CouchDB instance.

- Default: /usr/local/couchdb.

**NB!** Sub-folder with the ref name is automaticly added to this directory. See *ref2dir*

#####`ref2dir`

Add ref name as sub-folder of installation dir.

- Value: boolean (true/false)
- Default: *true*

#####`start_on_boot`

Start instance automaticly on node boot.

- Value: boolean (true/false)
- Default: *true*

#####`bind`

IP bind adress. CouchDB instance will be accessible only from this IP. Set to *0.0.0.0* to access CouchDB from any computer other than local.

- Value: IP
- Default: *0.0.0.0*

#####`port`

Instance port.

- Default: 5984

#####`www_auth`

Enable Http-Authentication. 

- Value: boolean (true/false)
- Default: *false*

#####`admin_login`

If *www_auth* is setted to *true*, set admin user login to this parameter.

- Default: *[not setted]*

#####`admin_password`

If *www_auth* is setted to *true*, set admin user password to this parameter.

- Default: *[not setted]*

#####`cors`

Enable [CORS](http://en.wikipedia.org/wiki/Cross-origin_resource_sharing "CORS wikipedia") on this instance. By enabling CORS functionality, a CouchDB instance can accept direct connections to protected DBs and instances, without the browser functionality being blocked due to the same origin constraint. 

- Value: boolean (true/false)
- Default: *false*

#####`cors_origins`

Domains than allowed to serve a data from this CouchDB instance.

- Default: *

#####`cors_headers`

Restricted Accepted Headers

- Default: *Access-Control-Allow-Headers,Content-Type,Authorization,Content-Length,X-Requested-With,Accept*

####couchdb::db

#####`dbname`

Database name.

#####`target`

Instance target URL. If you protect instance by login/password, use URL in form: http(s)://login:password@URI:PORT

- Default: http://127.0.0.1:5984

#####`source`

Source URL where this database will be replecated from.

- Default: *[empty]*

##Limitations

This module has been tested on:

* RedHat Enterprise Linux
	* 4
	* 5
	* 6
	* 7
* CentOS
	* 5 
	* 6
* Debian
	* 5 
	* 6
	* 7
* Ubuntu
	* 9
	* 10
	* 11 
