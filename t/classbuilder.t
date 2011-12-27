#!/usr/bin/env perl

use Test::Most;

BEGIN { use_ok('MC::ClassBuilder', MCTest => qw( one two )) }

throws_ok { MC::ClassBuilder->import() }
    qr/name parameter is required/,
    'ClassBuilder requires name parameter';

throws_ok { MC::ClassBuilder->import(q(Bad'Name)) }
    qr/"Bad'Name" is not a valid module prefix/,
    'ClassBuilder requires name parameter to be a valid module name';

throws_ok { MC::ClassBuilder->import('Good::Name') }
    qr/At least one method name must be specified/,
    'ClassBuilder requires at least one method in the interface';

throws_ok {
        package MCTest::Tail::Fail;
        use Moose;
        with 'MCTest::Role::Tail';
    } qr/'MCTest::Role::Tail' requires the methods 'one' and 'two'/,
    'Tail role exists and requires the interface';

lives_ok {
    package MCTest::Tail;
    use Moose;
    with 'MCTest::Role::Tail';
    sub one { 'MCTest::Tail::one' }
    sub two {
        my ($self, $head) = @_;
        __PACKAGE__ . ',' . ref $head;
    }
} 'Can consume tail role';

my $tail;
lives_ok { $tail = MCTest::Tail->new } 'Can create tail object';
isa_ok($tail, 'MCTest::Tail');
is($tail->one($tail), 'MCTest::Tail::one', 'MCTest::Tail::one works');
is($tail->two($tail), 'MCTest::Tail,MCTest::Tail', 'MCTest::Tail::two works');

throws_ok {
        package MCTest::Body::Fail;
        use Moose;
        with 'MCTest::Role::Body';
    } qr/'MCTest::Role::Body' requires the methods 'one' and 'two'/,
    'Body role exists and requires the interface';

lives_ok {
    package MCTest::Body;
    use Moose;
    with 'MCTest::Role::Body';
    sub one { 'MCTest::Body::one' }
    sub two {
        my ($self, $head) = @_;
        join(',', __PACKAGE__, ref($head), $self->tail->two($head));
    }
} 'Can consume body role';

my $body;
throws_ok { $body = MCTest::Body->new }
    qr/Attribute \(tail\) is required/, 'Body object requires tail parameter';
throws_ok { $body = MCTest::Body->new(tail => [qw( something )]) }
    qr/Attribute \(tail\) does not pass the type constraint/,
    'Body object requires tail parameter to do Tail';
lives_ok { $body = MCTest::Body->new(tail => $tail) }
    'Can create body object with tail';
isa_ok($body, 'MCTest::Body');
isa_ok($body->tail, 'MCTest::Tail');
is($body->tail, $tail, 'Tail is original tail');
is($body->one($body), 'MCTest::Body::one', 'MCTest::Body::one works');
is($body->two($body), 'MCTest::Body,MCTest::Body,MCTest::Tail,MCTest::Body',
    'MCTest::Body::two works');

my $body2;
lives_ok { $body2 = MCTest::Body->new(tail => $body) }
    'Can create another body object with body as tail';
isa_ok($body2, 'MCTest::Body');
isa_ok($body2->tail, 'MCTest::Body');
is($body2->tail, $body, 'First tail is original body');
isa_ok($body2->tail->tail, 'MCTest::Tail');
is($body2->tail->tail, $tail, 'Second tail is original tail');
is($body2->one($body), 'MCTest::Body::one', 'Nested MCTest::Body::one works');
is($body2->two($body), 'MCTest::Body,MCTest::Body,MCTest::Body,MCTest::Body,MCTest::Tail,MCTest::Body',
    'Nested MCTest::Body::two works');
throws_ok { $body2->tail($tail) }
    qr/Cannot assign a value to a read-only accessor/,
    'Tail accessor is ro';

my $head;
throws_ok { $head = MCTest::Head->new }
    qr/Attribute \(body\) is required/, 'Head object requires body parameter';
lives_ok { $head = MCTest::Head->new(body => $body2) }
    'Can create head with top-level body';
isa_ok($head, 'MCTest::Head');
isa_ok($head->body, 'MCTest::Body');
is($head->body, $body2, 'First body part is top-level body');
isa_ok($head->body->tail, 'MCTest::Body');
is($head->body->tail, $body, 'Second body part is second body');
isa_ok($head->body->tail->tail, 'MCTest::Tail');
is($head->body->tail->tail, $tail, 'Third body part is original tail');
is($head->one, 'MCTest::Body::one', 'Head method one works');
is($head->two, 'MCTest::Body,MCTest::Head,MCTest::Body,MCTest::Head,MCTest::Tail,MCTest::Head', 'Head method two works');


my $head2;
throws_ok { $head2 = MCTest::Head->new(body => $head) }
    qr/Attribute \(body\) does not pass the type constraint/,
    'Head object requires body parameter to do Tail';
lives_ok { $head2 = MCTest::Head->new(body => $tail) }
    'Can create head with tail as body';
isa_ok($head2, 'MCTest::Head');
isa_ok($head2->body, 'MCTest::Tail');
is($head2->body, $tail, 'Body is original tail');
is($head2->one, 'MCTest::Tail::one', 'MCTest::Head::one works');
is($head2->two, 'MCTest::Tail,MCTest::Head', 'MCTest::Head::two works');

throws_ok { $head2->body($head) }
    qr/Cannot assign a value to a read-only accessor/,
    'Body accessor is ro';

done_testing();
