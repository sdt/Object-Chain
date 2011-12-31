#!/usr/bin/env perl

use Test::Most;

BEGIN { use_ok('Object::Chain::ClassBuilder', ADTest => qw( set_context )) }
BEGIN { use_ok('Object::Chain::Composer') }

{
    package ADTest::Tail::Context;

    use Moose;
    with 'ADTest::Role::Tail';

    has last_context => ( is => 'ro', writer => '_set_last_context' );

    sub set_context {
        my $self = shift;

        if (wantarray) {
            $self->_set_last_context('array');
        }
        elsif (defined wantarray) {
            $self->_set_last_context('scalar');
        }
        else {
            $self->_set_last_context('void');
        }
    }
}

my $tail;
lives_ok { $tail = ADTest::Tail::Context->new } 'Create context tail';

$tail->set_context($tail);
is($tail->last_context, 'void', 'direct void context detected');

my ($scalar, @array);
$scalar = $tail->set_context($tail);
is($tail->last_context, 'scalar', 'direct scalar context detected');

@array = $tail->set_context($tail);
is($tail->last_context, 'array', 'direct array context detected');

{
    package ADTest::Body::Delegated;

    use Moose;
    use Object::Chain::Body::AutoDelegate qw( set_context );
    with 'ADTest::Role::Body';
}

my $body;
lives_ok { $body = ADTest::Body::Delegated->new(tail => $tail) }
    'Create delegated body';

$body->set_context($body);
is($tail->last_context, 'void', 'delegated void context detected');

$scalar = $body->set_context($body);
is($tail->last_context, 'scalar', 'delegated scalar context detected');

@array = $body->set_context($body);
is($tail->last_context, 'array', 'delegated array context detected');

my $head;
lives_ok { $head = ADTest::Head->new(body => $body) } 'Create head';

$head->set_context;
is($tail->last_context, 'void', 'head void context detected');

$scalar = $head->set_context;
is($tail->last_context, 'scalar', 'head scalar context detected');

@array = $head->set_context;
is($tail->last_context, 'array', 'head array context detected');

my $chain;
lives_ok { $chain = Object::Chain::Composer::compose(ADTest =>
                    [ qw( Context Delegated Delegated ) ])
         } 'Compose double-delegate chain';
my $chtail = $chain->body->tail->tail;

$chain->set_context;
is($chtail->last_context, 'void', 'chained void context detected');

$scalar = $chain->set_context;
is($chtail->last_context, 'scalar', 'chained scalar context detected');

@array = $chain->set_context;
is($chtail->last_context, 'array', 'chained array context detected');

done_testing();
