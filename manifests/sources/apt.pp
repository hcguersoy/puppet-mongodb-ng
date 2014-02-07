class mongodb::sources::apt inherits mongodb::params {
  include apt

  if $mongodb::install::location {
    $location = $mongodb::install::location
  } else {
    $location = $mongodb::params::locations[$mongodb::params::init]
  }

  apt::source { '10gen':
    location    => $location,
    release     => 'dist',
    repos       => '10gen',
    key         => '7F0CEB10',
    key_server  => 'keyserver.ubuntu.com',
    include_src => false,
  }
}
