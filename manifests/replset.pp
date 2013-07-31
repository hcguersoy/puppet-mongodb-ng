# Define to initialise a replica set.
# 
# $replset:         the name of the replica set
# $replsetmembers:  an array of hashes, containing the replica set member and their ports
#                   and some configuration details.
#                   The first member in the array will be picked as the master.
#                   like: 
#                   $replsetmembers = [
#                        {'host' => 'simplebox1', 'port' => '27017'},
#                        {'host' => 'simplebox2', 'port' => '27017'},
#                    ]
#                   Allowed keys are ate current:
#                   host, port, arbiteronly, indexes (sets buildIndexes), hidden and priority.
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
    $firstmemberhost = $replsetmembers[0][host]
    $firstmemberport = $replsetmembers[0][port]

    notice($firstmemberhost)
    notice($firstmemberport)

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