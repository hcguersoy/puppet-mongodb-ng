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

### Installation using DPKG

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

### Replication sets

In this module, the setup of replica sets is supported.

Example:

    $replset1 = 'replset-1'

    mongodb {'mongo-1-1' :
        servicename     => 'mongo-1-1',
        port            => 27117,
        replset         => $replset1,
        oplogsize       => 16,
        smallfiles      => true,
    }

    mongodb {'mongo-1-2' :
        servicename     => 'mongo-1-2',
        port            => 27127,
        replset         => $replset1,
        oplogsize       => 16,
        smallfiles      => true,    
    }

    $replsetmembers = [
        {'host' => 'simplebox1', 'port' => '27117'},
        {'host' => 'simplebox1', 'port' => '27127'},
    ]

    mongodb::replset {"$replset1" :
        replset        => $replset1,
        replsetmembers => $replsetmembers,
        require        => [Service['mongo-1-1'], Service['mongo-1-2']]
    } 

Here, two nodes are configured and they have been told to be part of replica set 'replset-1'.
Additional, just because these mongo instances are only for testing in this case, we tell them
to have a realy small oplogsize (16 Mb) and to use small files.

With the class mongodb::replset we do the concrete replica configuration. The replica set members are 
listed in an array. In this definition a sleep time is build in before the mongo shell is executed 
because the startup of MongoDB can be time consuming due to creation of files. Before of this, the replica 
set configuration doesn't complain that any members are not ready. 
You can change the sleeptime via

    waittime       => '45s'

The sh sleep command is used for this, so you can use 'm', 's' etc. as time units.

### Sharding

This module supports now the configuration of a sharded system. 

A simple example with a shard consisting of

- one config server (you should NOT use only one config server in production! NEVER!)
- one mongos process
- two shard members

And you should realy never run this stuff in production in the same machine!

    $shardmembers = [
        {host => 'shardbox1', port => 27017},
        {host => 'shardbox1', port => 27117},
    ]


    mongodb {'mongo-cfg-1' :
        servicename     => 'mongo-cfg-1',
        port            => 27019,
        configsvr       => true,
    }

    mongodb::mongos {'mongo-s-1' :
        servicename     => 'mongo-s-1',
        port            => 27517,
        configdb        => 'shardbox1:27019',
        require         => Service['mongo-cfg-1']
    } 

    mongodb {'mongo-1-0' :
        servicename     => 'mongo-1-0',
        port            => $shardmembers[0][port],
        smallfiles      => true,
    }

    mongodb {'mongo-1-1' :
        servicename     => 'mongo-1-1',
        port            => $shardmembers[1][port],
        smallfiles      => true,    
    }

    mongodb::shard {'shard1' :
        shardmembers    => $shardmembers,
        mongos          => {host => 'shardbox1', port => 27517},
        require         => [Service['mongo-s-1'], Service['mongo-1-0'], Service['mongo-1-1']]
    }

### Next steps

The next steps are:

* removing old, unused code
* removing initial installed configuration files
* better support for replication and sharding
* support for Red Hat / CentOS

## Limitations

Due to the fact that the variables in defines are not accessible I use an array of hashes to pass the parameters of the members.
If you have any elegant idea how we can use here defines - let it me know. 

## More examples

More examples could be found (in the future) at https://github.com/hcguersoy/puppet-mongodb-ng-example

## Supported Platforms

* Debian Wheezy - untested
* Ubuntu 12.04 (precise) - tested

Contributions for RH/CentOS are welcome.
