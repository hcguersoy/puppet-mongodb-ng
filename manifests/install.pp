# installs mongodb from distributed packages
# but doesn't configure any instance.
# Instead of this, the original service will be
# disabled.
# TODO delete original upstart and config file

class mongodb::install (
    $location        = undef,
    $init            = $mongodb::params::init,
    $enable_10gen    = false,
    $enable_dpkg     = false,
    $deb_file        = undef,
    $packagename     = undef,    
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

  # disable the original service as
  # we want to configure different instances
  # with different names
  service { $orig_service :
    name      => $orig_service,
    ensure    => stopped,
    enable    => false,
    require   => Package['mongodb-10gen'],
  }

}
