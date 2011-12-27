package MC::ClassBuilder;

use strict;
use warnings;

# VERSION
# ABSTRACT: Automatically create Head class, and Body and Tail roles.

use Moose ();

my $head_method_wrapper = sub {
    my ($orig, $self, @args) = @_;
    $self->$orig($self, @args); # 2nd $self is $head param
};

sub import {
    my ($class, $name, @methods) = @_;

    my $ifname = $name . '::Role::Interface';
    my $ifrole = Moose::Meta::Role->create($ifname);
    $ifrole->add_required_methods(@methods);

    my $tailname = $name . '::Role::Tail';
    my $tailrole = Moose::Meta::Role->create($tailname,
            roles => [ $ifname ],
        );

    my $bodyname = $name . '::Role::Body';
    my $bodyrole = Moose::Meta::Role->create($bodyname,
            roles => [ $ifname ],
            attributes => {
                tail => {
                    is => 'ro',
                    does => $ifname,
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
                        does        => $ifname,
                        required    => 1,
                        handles     => \@methods,
                    ),
                ),
            ],
            superclasses => [qw( Moose::Object )],
            xaround => { this => 'hats' },
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

    # Interface role - this specifies the interface for the centipede.
    package MyCentipede::Role::Interface;
    use Moose::Role;
    requires qw( get set );

    # Tail role - consuming classes must implement the interface.
    package MyCentipede::Role::Tail;
    use Moose::Role;
    with 'MyCentipede::Role::Interface';

    # Body role - consuming classes must implement the interface, and also
    # have a tail attribute.
    package MyCentipede::Role::Body;
    use Moose::Role;
    with 'MyCentipede::Role::Interface';
    has tail => (
        is       => 'ro',
        does     => 'MyCentipede::Role::Interface',
        required => 1,
    );

    # Head class. This is just a convenience class which automatically wraps
    # the interface methods so they provide the $head parameter.
    package MyCentipede::Head;
    use Moose;
    has body => (
        is          => 'ro',
        does        => 'MyCentipede::Role::Interface',
        required    => 1,
        handles     => [qw( get set )],
    );
    around [qw( get set )] => sub {
        my ($orig, $self, @args) = @_;
        $self->$orig($self, @args);
    };

=cut

