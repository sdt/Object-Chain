package MC::ClassBuilder;

use strict;
use warnings;

sub build {
    my ($name, @methods) = @_;
    my $methods = join(' ', @methods);

    eval <<"END";

package MC::Role::Tail::$name;
use Moose::Role;
use namespace::autoclean;

requires qw( $methods );

package MC::Role::Body::$name;
use Moose::Role;
use namespace::autoclean;

with 'MC::Role::Tail::$name';

has inner => (
    is       => 'ro',
    does     => 'MC::Role::Tail::$name',
    required => 1,
);

package MC::Head::$name;
use Moose;
use namespace::autoclean;

has body => (
    is          => 'ro',
    does        => 'MC::Role::Tail::$name',
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
