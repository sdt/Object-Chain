#!/usr/bin/env perl

use Test::Most;

BEGIN { use_ok('MC::ClassBuilder', Test => qw( one two )) }

throws_ok {
        package Test::Tail::Fail;
        use Moose;
        with 'Test::Role::Tail';
    } qr/'Test::Role::Tail' requires the methods 'one' and 'two'/,
    'Tail role exists and requires the interface';

lives_ok {
    package Test::Tail;
    use Moose;
    with 'Test::Role::Tail';
    sub one { 'Test::Tail::one' }
    sub two {
        my ($self, $head) = @_;
        __PACKAGE__ . ',' . ref $head;
    }
} 'Can consume tail role';

my $tail;
lives_ok { $tail = Test::Tail->new } 'Can create tail object';
isa_ok($tail, 'Test::Tail');
is($tail->one($tail), 'Test::Tail::one', 'Test::Tail::one works');
is($tail->two($tail), 'Test::Tail,Test::Tail', 'Test::Tail::two works');

throws_ok {
        package Test::Body::Fail;
        use Moose;
        with 'Test::Role::Body';
    } qr/'Test::Role::Body' requires the methods 'one' and 'two'/,
    'Body role exists and requires the interface';

lives_ok {
    package Test::Body;
    use Moose;
    with 'Test::Role::Body';
    sub one { 'Test::Body::one' }
    sub two {
        my ($self, $head) = @_;
        join(',', __PACKAGE__, ref($head), $self->tail->two($head));
    }
} 'Can consume body role';

my $body;
throws_ok { $body = Test::Body->new }
    qr/Attribute \(tail\) is required/, 'Body object requires tail parameter';
throws_ok { $body = Test::Body->new(tail => [qw( something )]) }
    qr/Attribute \(tail\) does not pass the type constraint/,
    'Body object requires tail parameter to do Tail';
lives_ok { $body = Test::Body->new(tail => $tail) }
    'Can create body object with tail';
isa_ok($body, 'Test::Body');
isa_ok($body->tail, 'Test::Tail');
is($body->tail, $tail, 'Tail is original tail');
is($body->one($body), 'Test::Body::one', 'Test::Body::one works');
is($body->two($body), 'Test::Body,Test::Body,Test::Tail,Test::Body',
    'Test::Body::two works');

my $body2;
lives_ok { $body2 = Test::Body->new(tail => $body) }
    'Can create another body object with body as tail';
isa_ok($body2, 'Test::Body');
isa_ok($body2->tail, 'Test::Body');
is($body2->tail, $body, 'First tail is original body');
isa_ok($body2->tail->tail, 'Test::Tail');
is($body2->tail->tail, $tail, 'Second tail is original tail');
is($body2->one($body), 'Test::Body::one', 'Nested Test::Body::one works');
is($body2->two($body), 'Test::Body,Test::Body,Test::Body,Test::Body,Test::Tail,Test::Body',
    'Nested Test::Body::two works');
throws_ok { $body2->tail($tail) }
    qr/Cannot assign a value to a read-only accessor/,
    'Tail accessor is ro';

my $head;
throws_ok { $head = Test::Head->new }
    qr/Attribute \(body\) is required/, 'Head object requires body parameter';
lives_ok { $head = Test::Head->new(body => $body2) }
    'Can create head with top-level body';
isa_ok($head, 'Test::Head');
isa_ok($head->body, 'Test::Body');
is($head->body, $body2, 'First body part is top-level body');
isa_ok($head->body->tail, 'Test::Body');
is($head->body->tail, $body, 'Second body part is second body');
isa_ok($head->body->tail->tail, 'Test::Tail');
is($head->body->tail->tail, $tail, 'Third body part is original tail');
is($head->one, 'Test::Body::one', 'Head method one works');
is($head->two, 'Test::Body,Test::Head,Test::Body,Test::Head,Test::Tail,Test::Head', 'Head method two works');


my $head2;
throws_ok { $head2 = Test::Head->new(body => $head) }
    qr/Attribute \(body\) does not pass the type constraint/,
    'Head object requires body parameter to do Tail';
lives_ok { $head2 = Test::Head->new(body => $tail) }
    'Can create head with tail as body';
isa_ok($head2, 'Test::Head');
isa_ok($head2->body, 'Test::Tail');
is($head2->body, $tail, 'Body is original tail');
is($head2->one, 'Test::Tail::one', 'Test::Head::one works');
is($head2->two, 'Test::Tail,Test::Head', 'Test::Head::two works');

throws_ok { $head2->body($head) }
    qr/Cannot assign a value to a read-only accessor/,
    'Body accessor is ro';

done_testing();
