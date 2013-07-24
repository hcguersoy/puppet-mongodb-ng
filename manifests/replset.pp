# Define to initialise a replica set.
# 
# $replset:         the name of the replica set
# $replsetmembers:  an array of array, containing the replica set member and their ports
#                   like: replsetmembers => [['localhost', 27117], ['localhost', 27127]],
# $waittime:        how long puppet should waild before firing up the rs initialisation
# $mongoexec:       the mongo executable, defaults to /usr/bin/mongo

define mongodb::replset(
    $replset        = undef,
    $replsetmembers = undef,
    $waittime       = '15s',
    $mongoexec      = '/usr/bin/mongo',
) {

    # pick the host and port of the first member in the list
    # this node is used to configure the replica set
    $firstmemberhost = $replsetmembers[0][0]
    $firstmemberport = $replsetmembers[0][1]

    file { "/tmp/$replset-initconf.js" :
        content => template('mongodb/replset-init.js.erb'),
        owner   => 'mongodb',
        group   => 'mongodb',
        mode    => '0644',
    }

    exec { "sh -c 'sleep $waittime; $mongoexec $firstmemberhost:$firstmemberport /tmp/$replset-initconf.js'":
        path      => '/bin/',
        require   => File["/tmp/$replset-initconf.js"], 
        subscribe => File["/tmp/$replset-initconf.js"], 
    }
} # mongodb::replset