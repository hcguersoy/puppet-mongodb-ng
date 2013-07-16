class mongodb::params{
  notice ("Im on ${::osfamily}")
  notice ("$enable_10gen")
  notice ("$enable_dpkg")
  case $::osfamily {
    'redhat': {
      $baseurl = "http://downloads-distro.mongodb.org/repo/redhat/os/${::architecture}"
      $source  = 'mongodb::sources::yum'
      $package = 'mongodb-server'
      $orig_service = 'mongod'
      $pkg_10gen = 'mongo-10gen-server'
    }
    'debian': {
      $locations = {
        'sysv'    => 'http://downloads-distro.mongodb.org/repo/debian-sysvinit',
        'upstart' => 'http://downloads-distro.mongodb.org/repo/ubuntu-upstart'
      }
      case $::operatingsystem {
        'Debian': { $init = 'sysv' }
        'Ubuntu': { $init = 'upstart' }
      }
      $package = 'mongodb'
      # using a different name as the default one
      $orig_service = 'mongodb'
      $pkg_10gen = 'mongodb-10gen'
    }
    default: {
      fail ("mongodb: ${::operatingsystem} is not supported.")
    }
  }
}
