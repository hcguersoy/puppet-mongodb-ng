# == Class: mongos
#
# === Parameters
#
# === Examples
#
# === TODOs
#
# Support for
# - maxConns
# - noAutoSplit
#
# === Authors
#
# Halil-Cem Gürsoy <hcguersoy@gmail.com>

define mongodb::mongos (
  $servicename     = undef,
  $logpath         = "/var/log/mongodb/$servicename/",
  $logfile         = "$servicename.log",
  $logappend       = true,
  $verbose         = undef,
  $mongofork       = true,
  $bind_ip         = undef,
  $port            = '27017',
  $objcheck        = undef,
  $nohttpinterface = true,
  $noscripting     = undef,  
  $configdb        = undef,
  $chunkSize       = undef,
  $config_file     = "/etc/$servicename-routerconfig.conf",
  $hname           = $hostname,     
  $waittime        = '15s',
) {

  # log path
  file { "logdir-${servicename}" :
    ensure  => 'directory',
    path    => $logpath,
    owner   => 'mongodb',
    group   => 'mongodb',
    mode    => '0644',
    require => Package['mongodb-10gen'],
  }  
 
  # create the configfile used by the mongos service
  # each service should have its own config file
  file { $config_file :
    content => template('mongodb/mongos.conf.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => [Package['mongodb-10gen'], File[$logpath]]
  }

  # the upstart config file
  # contributions are welcome for RH/CentOs or SUSE
  # as this is Ubuntu/Debian specific
  # Each service needs its own file.
  file { "/etc/init/$servicename.conf" :
    content => template('mongodb/mongos-init.conf.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => File[$config_file]
  }

  exec { "sh -c 'sleep $waittime;'":
      path      => '/bin/',
      require   => File["/etc/init/$servicename.conf"], 
  }

  # the servicename should be unique and 
  # not 'mongodb' as this collides with the 
  # original name
  service { $servicename :
    name      => $servicename,
    ensure    => running,
    enable    => true,
    require   => [File["/etc/init/$servicename.conf"], Exec["sh -c 'sleep $waittime;'"]],
    subscribe => File[$config_file],
  }
} # Define mongos
