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
# === Copyright
#
# Copyright 2012 PuppetLabs
#
class mongodb (
  $enable_10gen    = false,
  $init            = $mongodb::params::init,
  $location        = '',
  $packagename     = undef,
  $servicename     = undef,
  $logpath         = '/var/log/mongodb/',
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
  $nohttpinterface = undef,
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
  $enable_dpkg     = false,
  $deb_file        = undef,
  $config_file     = "/etc/$servicename-dbconfig.conf",
) inherits mongodb::params {

  if ($enable_10gen or $enable_dpkg) {
    if $enable_10gen {
      $deb_source  = 'mongodb::sources::apt'
      notice ("10gen is true")
    } elsif $enable_dpkg {
      $deb_source  = 'mongodb::sources::dpkg'
      notice ("dpkg is true")
    }
    include $deb_source
    Class[$deb_source] -> Package['mongodb-10gen']
  }

  if $packagename {
    $package = $packagename
  } elsif ($enable_10gen or $enable_dpkg) {
    $package = $mongodb::params::pkg_10gen
  } else {
    $package = $mongodb::params::package
  }

  package { 'mongodb-10gen':
    name   => $package,
    ensure => installed,
  }

  #create directory needed by the db
  # log path
  file { $logpath :
    ensure  => 'directory',
    owner   => 'mongodb',
    group   => 'mongodb',
    mode    => '0644',
    require => Package['mongodb-10gen'],
  }  

  # db path
  file { $dbpath :
    ensure  => 'directory',
    owner   => 'mongodb',
    group   => 'mongodb',
    mode    => '0644',
    require => Package['mongodb-10gen'],
  }  

  file { $config_file :
    content => template('mongodb/mongod.conf.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => [Package['mongodb-10gen'], File[$dbpath], File[$logpath]]
  }

  # the upstart config file
  # contributions are welcome for RH/CentOs
  # as this is Ubuntu/Debian specific
  file { "/etc/init/$servicename.conf" :
    content => template('mongodb/mongoinit.conf.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => File[$config_file]
  }

  # disable the original service as
  # we want to configure different instances
  # with different names
  service { $orig_service :
    name      => $orig_service,
    ensure    => stopped,
    enable    => false,
  }

  service { $servicename :
    name      => $servicename,
    ensure    => running,
    enable    => true,
    require   => [Service[$orig_service], File["/etc/init/$servicename.conf"]],
    subscribe => File[$config_file],
  }
}
