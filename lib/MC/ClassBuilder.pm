package MC::ClassBuilder;

use strict;
use warnings;

sub import {
    my ($class, $name, @methods) = @_;

    _create_tail_role($name, @methods);
    _create_body_role($name, @methods);
    _create_head_class($name, @methods);
}

sub _create_tail_role {
    my ($name, @methods) = @_;
    my $methods = join(' ', @methods);

    eval <<"END";
package ${name}::Role::Tail;
use Moose::Role;
use namespace::autoclean;

requires qw( $methods );

1;
END
}

sub _create_body_role {
    my ($name, @methods) = @_;

    eval <<"END";
package ${name}::Role::Body;
use Moose::Role;
use namespace::autoclean;

with '${name}::Role::Tail';

has tail => (
    is       => 'ro',
    does     => '${name}::Role::Tail',
    required => 1,
);
1;
END
}

sub _create_head_class {
    my ($name, @methods) = @_;
    my $methods = join(' ', @methods);

    eval <<"END";
package ${name}::Head;
use Moose;
use namespace::autoclean;

has body => (
    is          => 'ro',
    does        => '${name}::Role::Tail',
    required    => 1,
    handles     => [qw( $methods )],
);

around [qw( $methods )] => sub {
    my (\$orig, \$self, \@args) = \@_;
    \$self->\$orig(\$self, \@args);
};

1;
END
}

1;
