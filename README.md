# mongodb puppet module

## Overview

Installs mongodb on Ubuntu/Debian from OS repo, or alternatively per 10gen [installation documentation](http://www.mongodb.org/display/DOCS/Ubuntu+and+Debian+packages).

## Usage

### class mongodb

Parameters:
* enable_10gen (default: false) - Whether or not to set up 10gen software repositories
* init (auto discovered) - override init (sysv or upstart) for Debian derivatives
* location - override apt location configuration for Debian derivatives
* packagename (auto discovered) - override the package name
* servicename (auto discovered) - override the service name

By default ubuntu is upstart and debian uses sysv.

Examples:

    class mongodb {
      init => 'sysv',
    }

    class mongodb {
      enable_10gen => true,
    }


## Changes to the original
In this fork, installation on Ubuntu/Debian is supported by DPKG. For this, you have to provide a DEB file and tell the class there to find this:

    class {'mongodb::install':
        enable_dpkg     => true,
        deb_file        => '/tmp/mongodbfiles/mongodb-10gen_2.4.5_amd64.deb',
    }

Additionaly, you can now start multiple mongodb instances. The only requirement is that you don't use the service name "mongodb":

    mongodb {'mongo-1' :
        servicename     => 'mongo-1',
        port            => 27117,
    }

    mongodb {'mongo-2' :
        servicename     => 'mongo-2',
        port            => 27127,
    }

Due to this changes RH/CentOS is at the moment not supprted.

The next steps are:

* defines for mongos, arbiter, configserver
* support for replica-sets and sharding
* and many many other stuff    

## Supported Platforms

* Debian Wheezy - untested
* Ubuntu 12.04 (precise) - tested

Contributions for RH/CentOS are welcome.
