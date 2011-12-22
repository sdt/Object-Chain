package MC::ClassBuilder;

use strict;
use warnings;

sub import {
    my ($class, $name, @methods) = @_;
    my $methods = join(' ', @methods);

    my $code = <<"END";

package ${name}::Role::Tail;
use Moose::Role;
use namespace::autoclean;

requires qw( $methods );

package ${name}::Role::Body;
use Moose::Role;
use namespace::autoclean;

with '${name}::Role::Tail';

has tail => (
    is       => 'ro',
    does     => '${name}::Role::Tail',
    required => 1,
);

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

    # print STDERR $code;
    eval $code;
}

1;
