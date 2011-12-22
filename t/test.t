#!/usr/bin/env perl

use strict;
use warnings;

use File::Temp ();
use Test::Most;

BEGIN {
    use_ok 'KVStore::Tail::Storable';
    use_ok 'KVStore::Body::HashCached';
    use_ok 'KVStore::Body::Check';
};

{
    my $dbfile = File::Temp->new();
    my $tail;
    lives_ok { $tail = KVStore::Tail::Storable->new(
            filename => $dbfile->filename ) }
        'Can create tail Storable object';

    test_tail_kvstore($tail, 'Storable');
}

{
    my $dbfile = File::Temp->new();
    my $tail;
    lives_ok { $tail = KVStore::Tail::Storable->new(
            filename => $dbfile->filename ) }
        'Can create tail Storable object';

    my $cache;
    lives_ok { $cache = KVStore::Body::HashCached->new(
            tail => $tail) }
        'Can create body HashCached object';

    test_tail_kvstore($tail, 'HashCached');
}

{
    my $dbfile = File::Temp->new();
    my $tail;
    lives_ok { $tail = KVStore::Tail::Storable->new(
            filename => $dbfile->filename ) }
        'Can create tail Storable object';

    my $cache;
    lives_ok { $cache = KVStore::Body::HashCached->new(
            tail => $tail) }
        'Can create body HashCached object';

    my $check;
    lives_ok { $check = KVStore::Body::Check->new(
            tail => $cache) }
        'Can create body Check object';

    my $head;
    lives_ok { $head = KVStore::Head->new(
            body => $check) }
        'Can create head object';

    test_head_kvstore($head, 'Head');
}

sub test_head_kvstore {
    my ($kv, $name) = @_;

    my %test_values = ( 'one' => 1, 'two' => 2, 'three' => 3 );
    while (my ($key, $value) = each %test_values) {
        lives_ok { $kv->set($key, $value) }
            "$name->set('$key', $value) lives";
    }

    while (my ($key, $value) = each %test_values) {
        my $got;
        lives_ok { $got = $kv->get($key) }
            "$name->get('$key') lives";
        is($got, $value, "$name->get('$key') is $value");
    }
}

sub test_tail_kvstore {
    my ($kv, $name) = @_;

    my %test_values = ( 'one' => 1, 'two' => 2, 'three' => 3 );
    while (my ($key, $value) = each %test_values) {
        lives_ok { $kv->set($kv, $key, $value) }
            "$name->set(\$head, '$key', $value) lives";
    }

    while (my ($key, $value) = each %test_values) {
        my $got;
        lives_ok { $got = $kv->get($kv, $key) }
            "$name->get(\$head, '$key') lives";
        is($got, $value, "$name->get(\$head, '$key') is $value");
    }
}

done_testing();
