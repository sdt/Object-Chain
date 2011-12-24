package MC::ClassBuilder;
# ABSTRACT: Automatically create Head class, and Body and Tail roles.

use strict;
use warnings;

use Moose::Meta::Instance;      # required for Moose::Meta::Attribute ?
use Moose::Meta::TypeCoercion;  # required for Moose::Meta::Attribute ?

use Moose::Meta::Attribute;
use Moose::Meta::Class;
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

    my $tailname = $name . '::Role::Tail';
    my $role = Moose::Meta::Role->create($tailname);
    $role->add_required_methods(@methods);

    $role{$tailname} = $role;
}

sub _create_body_roleX {
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

    my $role = Moose::Meta::Role->create($bodyname,
#            roles => [ $tailname ],    # not working?
            attributes => {
                tail => {
                    is => 'ro',
                    does => $tailname,
                    required => 1,
                },
            },
        );
    $role->add_role($role{$tailname});

    $role{$bodyname} = $role;
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

    # Effectively does this:
    #   package ${name}::Head;
    #   use Moose;
    #   has body => (
    #       is          => 'ro',
    #       does        => '${name}::Role::Tail',
    #       required    => 1,
    #       handles     => [qw( $methods )],
    #   );
    #   around [qw( $methods )] => sub {
    #       my ($orig, $self, @args) = @_;
    #       $self->$orig($self, @args);
    #   };

    my $headname = $name . '::Head';
    my $tailname = $name . '::Role::Tail';

    my $class;
    $class = Moose::Meta::Class->create($headname,
            attributes => [
                Moose::Meta::Attribute->new(
                    body => (
                        is          => 'ro',
                        does        => $tailname,
                        required    => 1,
                        handles     => \@methods,
                    ),
                ),
            ],
            superclasses => [qw( Moose::Object )],
        );
    for my $method (@methods) {
        $class->add_around_method_modifier($method, sub {
                my ($orig, $self, @args) = @_;
                $self->$orig($self, @args);
            });
    }
    $class->make_immutable;
}

1;
