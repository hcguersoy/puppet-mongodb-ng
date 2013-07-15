class mongodb::sources::dpkg inherits mongodb::params {

  if $mongodb::deb_file {
    $file = $mongodb::deb_file
  } else {
    raise Puppet::ParseError, "You must provide a deb file using the deb_file parameter"
  }

  #install here the mongodb deb file using dpkg provider
  #then the package 'mongodb-10gen' is processed, the package
  #is allready installed and it will continue.
  package { 'mongodb-deb':
    provider  => 'dpkg',
    name      => $package,
    ensure    => installed,
    source    => "$file",
  }

}
