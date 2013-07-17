# == Class: mongodb
#
# Manage mongodb installations on RHEL, CentOS, Debian and Ubuntu - either
# installing from the 10Gen repo or from EPEL in the case of EL systems.
#
# === Parameters
#
# enable_10gen (default: false) - Whether or not to set up 10gen software repositories
# init (auto discovered) - override init (sysv or upstart) for Debian derivatives
# location - override apt location configuration for Debian derivatives
# packagename (auto discovered) - override the package name
# servicename (auto discovered) - override the service name
#
# === Examples
#
# To install with defaults from the distribution packages on any system:
#   include mongodb
#
# To install from 10gen on a EL server
#   class { 'mongodb':
#     enable_10gen => true,
#   }
#
# === Authors
#
# Craig Dunn <craig@craigdunn.org>
#
# Forked and modief by
# Halil-Cem Gürsiy <hcguersoy@gmail.com>
#
# === Copyright
#
# Copyright 2012 PuppetLabs
#
define mongodb (
  $servicename     = undef,
  $logpath         = "/var/log/mongodb/$servicename/",
  $logfile         = "$servicename.log",
  $logappend       = true,
  $mongofork       = true,
  $port            = '27017',
  $dbpath          = "/var/lib/mongodb/$servicename",
  $nojournal       = undef,
  $cpu             = undef,
  $noauth          = undef,
  $auth            = undef,
  $verbose         = undef,
  $objcheck        = undef,
  $quota           = undef,
  $oplog           = undef,
  $nohints         = undef,
  $nohttpinterface = true,
  $noscripting     = undef,
  $notablescan     = undef,
  $noprealloc      = undef,
  $nssize          = undef,
  $mms_token       = undef,
  $mms_name        = undef,
  $mms_interval    = undef,
  $slave           = undef,
  $only            = undef,
  $master          = undef,
  $source          = undef,
  $config_file     = "/etc/$servicename-dbconfig.conf",
) {


  #create directories needed by the db

  # log path
  file { "logdir-${servicename}" :
    ensure  => 'directory',
    path    => $logpath,
    owner   => 'mongodb',
    group   => 'mongodb',
    mode    => '0644',
    require => Package['mongodb-10gen'],
  }  

  # db path
  file { "dbpath-${servicename}" :
    ensure  => 'directory',
    path    =>  $dbpath,
    owner   => 'mongodb',
    group   => 'mongodb',
    mode    => '0644',
    require => Package['mongodb-10gen'],
  }  

  # create the configfile used by the service
  # each service should have its own config file
  file { $config_file :
    content => template('mongodb/mongod.conf.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => [Package['mongodb-10gen'], File[$dbpath], File[$logpath]]
  }

  # the upstart config file
  # contributions are welcome for RH/CentOs or SUSE
  # as this is Ubuntu/Debian specific
  # Each service needs its own file.
  file { "/etc/init/$servicename.conf" :
    content => template('mongodb/mongoinit.conf.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => File[$config_file]
  }

  # the servicename should be unique
  service { $servicename :
    name      => $servicename,
    ensure    => running,
    enable    => true,
    require   => [File["/etc/init/$servicename.conf"]],
    subscribe => File[$config_file],
  }
}
