#!/usr/bin/env perl

use strict;
use warnings;

use File::Temp ();
use Test::Most;

BEGIN {
    use_ok 'MC::Base::KVStore::Storable';
    use_ok 'MC::Mutator::KVStore::HashCached';
    use_ok 'MC::Head::KVStore';
};

{
    my $dbfile = File::Temp->new();
    my $base;
    lives_ok { $base = MC::Base::KVStore::Storable->new(
            filename => $dbfile->filename ) }
        'Can create base Storable object';

    test_tail_kvstore($base, 'Storable');
}

{
    my $dbfile = File::Temp->new();
    my $base;
    lives_ok { $base = MC::Base::KVStore::Storable->new(
            filename => $dbfile->filename ) }
        'Can create base Storable object';

    my $cache;
    lives_ok { $cache = MC::Mutator::KVStore::HashCached->new(
            inner => $base) }
        'Can create mutator HashCached object';

    test_tail_kvstore($base, 'HashCached');
}

{
    my $dbfile = File::Temp->new();
    my $base;
    lives_ok { $base = MC::Base::KVStore::Storable->new(
            filename => $dbfile->filename ) }
        'Can create base Storable object';

    my $cache;
    lives_ok { $cache = MC::Mutator::KVStore::HashCached->new(
            inner => $base) }
        'Can create mutator HashCached object';

    my $head;
    lives_ok { $head = MC::Head::KVStore->new(
            body => $cache) }
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
