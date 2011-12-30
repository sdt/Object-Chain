#!/usr/bin/env perl

use Test::Most;
use File::Temp ();
use lib './examples/lib';

BEGIN { use_ok('Object::Chain::Composer') }
BEGIN { use_ok('KVStore') }

{
    my $dbfile = File::Temp->new();
    my $chaindef = {
        KVStore => [
            { Storable => { filename => $dbfile->filename, something => 1 } },
            { Compress => { } },
            qw( Profiler HashCached Profiler ),
        ],
    };

    my $chain = Object::Chain::Composer::compose(%$chaindef);
    explain($chain);

    $chain->set('one', 1);

    explain($chain);

    $chain->get('one', 1);
    $chain->get('one', 1);

    explain($chain);
};

done_testing();
