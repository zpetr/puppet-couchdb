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

The couchdb module installs, configures, and manages the [CouchDB](http://couchdb.apache.org/ "CouchDB") instances on any CouchDB version starting from *1.3.0*.

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

Documentation in progress...

##Limitations

This module has been tested on:

* RedHat Enterprise Linux
	* 4
	* 5
	* 6
	* 7
* Debian
	* 6
	* 7
* Ubuntu
	* 10.04
	* 12.04
	* 14.04
