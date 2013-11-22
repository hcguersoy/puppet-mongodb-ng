# # Define: mongodb::shard
# Parameters:
# $shardmembers - a list of replicasets or individual nodes which 
# have to be added to the shard.
# e.g.:
# $shardmembers = [{host => 'simplebox1', port => 27017},{host => 'simplebox1', port => 27117},] 
# 
# or, then using replica sets for sharding
# 
# $shard1members = [
#     {replset => $replset1, host => $replset1members[0][host], port => $replset1members[0][port]},
#     {replset => $replset1, host => $replset1members[1][host], port => $replset1members[1][port]},
# ]
#
define mongodb::shard (
    $shardmembers   = undef,
    $mongos         = undef,
    $waittime       = '15s',
    $mongoexec      = '/usr/bin/mongo',
) {

    $mongoshost     = $mongos[host]
    $mongosport     = $mongos[port]

    file { "/tmp/shard-$name-initconf.js" :
        content => template('mongodb/shard-init.js.erb'),
        owner   => 'mongodb',
        group   => 'mongodb',
        mode    => '0644',
    }

    # connect mongos and execute init script for shard
    exec { "sh -c 'sleep $waittime; $mongoexec $mongoshost:$mongosport /tmp/shard-$name-initconf.js'":
        path      => '/bin/',
        require   => File["/tmp/shard-$name-initconf.js"], 
        subscribe => File["/tmp/shard-$name-initconf.js"], 
    }

}