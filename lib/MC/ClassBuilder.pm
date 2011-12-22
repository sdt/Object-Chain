package MC::ClassBuilder;

use strict;
use warnings;

use Moose::Meta::Role;

my %role; #TODO: get rid of this once all the evals are gone

sub import {
    my ($class, $name, @methods) = @_;

    _create_tail_role($name, @methods);
    _create_body_role($name, @methods);
    _create_head_class($name, @methods);
}

sub _create_tail_role {
    my ($name, @methods) = @_;

    # Effectively does this:
    #   package ${name}::Role::Tail;
    #   use Moose::Role;
    #   requires @methods;

    my $fullname = $name . '::Role::Tail';
    my $role = Moose::Meta::Role->create($fullname);
    $role->add_required_methods(@methods);

    $role{$fullname} = $role;
}

sub _create_body_role {
    my ($name, @methods) = @_;

    # Effectively does this:
    #   package ${name}::Role::Body;
    #   use Moose::Role;
    #   with '${name}::Role::Tail';
    #   has tail => (
    #       is       => 'ro',
    #       does     => '${name}::Role::Tail',
    #       required => 1,
    #   );

    my $bodyname = $name . '::Role::Body';
    my $tailname = $name . '::Role::Tail';

    my $role = Moose::Meta::Role->create($bodyname);
    $role->add_role($role{$tailname});
    $role->add_required_methods(@methods); #TODO: should this be necessary?
    $role->add_attribute('tail',
            is => 'ro',
            does => $tailname,
            required => 1,
        );

    $role{$bodyname} = $role;
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
