package MC::Body::AutoDelegate;

use strict;
use warnings;

# VERSION
# ABSTRACT: Automatically delegate body methods to the tail object

sub import {
    my $class = shift;
    my $caller = scalar caller;
    for my $method_name (@_) {
        $caller->meta->add_method($method_name, sub {
                my $self = shift;
                # TODO: wantarray
                return $self->tail->$method_name(@_);
            });
    }
}

1;

__END__

=pod

=head1 SYNOPSIS

    package MyCentipede::Body::MyBody;
    use MC::Body::AutoDelegate qw( get ); # get delegates to $self->tail->get
    use MyCentipede;
    with MyCentipede::Role::Body;

    sub set {
        # ...
    }

=head1 DESCRIPTION

Sometimes you only want to implement part of your centipede interface, and let
the tail handle the rest.

It would be nice to be able to do this:

    package MyCentipede::MyBody;
    with 'MyCentipede::Role::Body';
    has '+tail' => (
        handles => 'get',
    );

But you get a circular dependency on the role and the tail attribute.
The body role can't be consumed without the get method, and the tail attribute
can't be delegated to until the body role has been consumed.

This module is a workaround. Instead, of the above, you do this:

    package MyCentipede::MyBody;
    use MC::Body::AutoDelegate qw( get );
    use MyCentipede;
    with 'MyCentipede::Role::Body';

=cut
