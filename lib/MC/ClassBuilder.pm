package MC::ClassBuilder;
# ABSTRACT: Automatically create Head class, and Body and Tail roles.

use strict;
use warnings;

use Moose ();

my $head_method_wrapper = sub {
    my ($orig, $self, @args) = @_;
    $self->$orig($self, @args); # 2nd $self is $head param
};

sub import {
    my ($class, $name, @methods) = @_;

    my $tailname = $name . '::Role::Tail';
    my $tailrole = Moose::Meta::Role->create($tailname);
    $tailrole->add_required_methods(@methods);

    my $bodyname = $name . '::Role::Body';
    my $bodyrole = Moose::Meta::Role->create($bodyname,
            roles => [ $tailname ],
            attributes => {
                tail => {
                    is => 'ro',
                    does => $tailname,
                    required => 1,
                },
            },
        );

    my $headname = $name . '::Head';
    my $headclass = Moose::Meta::Class->create($headname,
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
        $headclass->add_around_method_modifier($method, $head_method_wrapper);
    }
    $headclass->make_immutable;
}

1;

__END__

=pod

=head1 SYNOPSIS

    package MyCentipede;
    use MC::ClassBuilder MyCentipede => qw( get set );

    # Will automatically create the following roles and classes:

    # Tail role - consuming classes must implement the interface.
    package MyCentipede::Role::Tail;
    use Moose::Role;
    requires qw( get set );

    # Body role - consuming classes must implement the interface, and also
    # have a tail attribute.
    package MyCentipede::Role::Body;
    use Moose::Role;
    with 'MyCentipede::Role::Tail';
    has tail => (
        is       => 'ro',
        does     => 'MyCentipede::Role::Tail',
        required => 1,
    );

    # Head class. This is just a convenience class which automatically wraps
    # the interface methods so they provide the $head parameter.
    package MyCentipede::Head;
    use Moose;
    has body => (
        is          => 'ro',
        does        => 'MyCentipede::Role::Tail',
        required    => 1,
        handles     => [qw( get set )],
    );
    around [qw( get set )] => sub {
        my ($orig, $self, @args) = @_;
        $self->$orig($self, @args);
    };

=cut

