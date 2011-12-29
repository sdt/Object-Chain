#!/usr/bin/env perl

use Test::Most;

BEGIN { use_ok('Object::Chain::ClassBuilder', OCTest => qw( one two )) }

throws_ok { Object::Chain::ClassBuilder->import() }
    qr/name parameter is required/,
    'ClassBuilder requires name parameter';

throws_ok { Object::Chain::ClassBuilder->import(q(Bad'Name)) }
    qr/"Bad'Name" is not a valid module prefix/,
    'ClassBuilder requires name parameter to be a valid module name';

throws_ok { Object::Chain::ClassBuilder->import('Good::Name') }
    qr/At least one method name must be specified/,
    'ClassBuilder requires at least one method in the interface';

throws_ok {
        package OCTest::Tail::Fail;
        use Moose;
        with 'OCTest::Role::Tail';
    } qr/'OCTest::Role::Tail' requires the methods 'one' and 'two'/,
    'Tail role exists and requires the interface';

lives_ok {
    package OCTest::Tail;
    use Moose;
    with 'OCTest::Role::Tail';
    sub one { 'OCTest::Tail::one' }
    sub two {
        my ($self, $head) = @_;
        __PACKAGE__ . ',' . ref $head;
    }
} 'Can consume tail role';

my $tail;
lives_ok { $tail = OCTest::Tail->new } 'Can create tail object';
isa_ok($tail, 'OCTest::Tail');
is($tail->one($tail), 'OCTest::Tail::one', 'OCTest::Tail::one works');
is($tail->two($tail), 'OCTest::Tail,OCTest::Tail', 'OCTest::Tail::two works');

throws_ok {
        package OCTest::Body::Fail;
        use Moose;
        with 'OCTest::Role::Body';
    } qr/'OCTest::Role::Body' requires the methods 'one' and 'two'/,
    'Body role exists and requires the interface';

lives_ok {
    package OCTest::Body;
    use Moose;
    with 'OCTest::Role::Body';
    sub one { 'OCTest::Body::one' }
    sub two {
        my ($self, $head) = @_;
        join(',', __PACKAGE__, ref($head), $self->tail->two($head));
    }
} 'Can consume body role';

my $body;
throws_ok { $body = OCTest::Body->new }
    qr/Attribute \(tail\) is required/, 'Body object requires tail parameter';
throws_ok { $body = OCTest::Body->new(tail => [qw( something )]) }
    qr/Attribute \(tail\) does not pass the type constraint/,
    'Body object requires tail parameter to do Tail';
lives_ok { $body = OCTest::Body->new(tail => $tail) }
    'Can create body object with tail';
isa_ok($body, 'OCTest::Body');
isa_ok($body->tail, 'OCTest::Tail');
is($body->tail, $tail, 'Tail is original tail');
is($body->one($body), 'OCTest::Body::one', 'OCTest::Body::one works');
is($body->two($body), 'OCTest::Body,OCTest::Body,OCTest::Tail,OCTest::Body',
    'OCTest::Body::two works');

my $body2;
lives_ok { $body2 = OCTest::Body->new(tail => $body) }
    'Can create another body object with body as tail';
isa_ok($body2, 'OCTest::Body');
isa_ok($body2->tail, 'OCTest::Body');
is($body2->tail, $body, 'First tail is original body');
isa_ok($body2->tail->tail, 'OCTest::Tail');
is($body2->tail->tail, $tail, 'Second tail is original tail');
is($body2->one($body), 'OCTest::Body::one', 'Nested OCTest::Body::one works');
is($body2->two($body), 'OCTest::Body,OCTest::Body,OCTest::Body,OCTest::Body,OCTest::Tail,OCTest::Body',
    'Nested OCTest::Body::two works');
throws_ok { $body2->tail($tail) }
    qr/Cannot assign a value to a read-only accessor/,
    'Tail accessor is ro';

my $head;
throws_ok { $head = OCTest::Head->new }
    qr/Attribute \(body\) is required/, 'Head object requires body parameter';
lives_ok { $head = OCTest::Head->new(body => $body2) }
    'Can create head with top-level body';
isa_ok($head, 'OCTest::Head');
isa_ok($head->body, 'OCTest::Body');
is($head->body, $body2, 'First body part is top-level body');
isa_ok($head->body->tail, 'OCTest::Body');
is($head->body->tail, $body, 'Second body part is second body');
isa_ok($head->body->tail->tail, 'OCTest::Tail');
is($head->body->tail->tail, $tail, 'Third body part is original tail');
is($head->one, 'OCTest::Body::one', 'Head method one works');
is($head->two, 'OCTest::Body,OCTest::Head,OCTest::Body,OCTest::Head,OCTest::Tail,OCTest::Head', 'Head method two works');


my $head2;
throws_ok { $head2 = OCTest::Head->new(body => $head) }
    qr/Attribute \(body\) does not pass the type constraint/,
    'Head object requires body parameter to do Tail';
lives_ok { $head2 = OCTest::Head->new(body => $tail) }
    'Can create head with tail as body';
isa_ok($head2, 'OCTest::Head');
isa_ok($head2->body, 'OCTest::Tail');
is($head2->body, $tail, 'Body is original tail');
is($head2->one, 'OCTest::Tail::one', 'OCTest::Head::one works');
is($head2->two, 'OCTest::Tail,OCTest::Head', 'OCTest::Head::two works');

throws_ok { $head2->body($head) }
    qr/Cannot assign a value to a read-only accessor/,
    'Body accessor is ro';

done_testing();
