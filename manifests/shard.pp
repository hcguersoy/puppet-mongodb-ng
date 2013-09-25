# # Define: mongodb::shard
# Parameters:
# $shardmembers - a list of replicasets or individual nodes which 
# have to be added to the shard.
#
define mongodb::shard (
    $shardmembers   = undef,
    $mongos         = undef,
    $waittime       = '15s',
    $mongoexec      = '/usr/bin/mongo',
) {

    $mongoshost     = $mongos[host]
    $mongosport     = $mongos[port]

    file { "/tmp/shard-$mongoshost-initconf.js" :
        content => template('mongodb/shard-init.js.erb'),
        owner   => 'mongodb',
        group   => 'mongodb',
        mode    => '0644',
    }

    # connect mongos and execute init script for shard
    exec { "sh -c 'sleep $waittime; $mongoexec $mongoshost:$mongosport /tmp/shard-$mongoshost-initconf.js'":
        path      => '/bin/',
        require   => File["/tmp/shard-$mongoshost-initconf.js"], 
        subscribe => File["/tmp/shard-$mongoshost-initconf.js"], 
    }

}