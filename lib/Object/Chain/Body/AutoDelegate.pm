package Object::Chain::Body::AutoDelegate;

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
                return $self->tail->$method_name(@_);
            });
    }
}

1;

__END__

=pod

=head1 SYNOPSIS

    package MyChain::Body::MyBody;
    use Object::Chain::Body::AutoDelegate qw( get ); # auto-delegated to tail
    use MyChain;
    with 'MyChain::Role::Body';

    sub set {
        # ...
    }

=head1 DESCRIPTION

Sometimes you only want to implement part of your chain's interface, and let
the tail handle the rest.

It would be nice to be able to do this:

    package MyChain::MyBody;
    with 'MyChain::Role::Body';
    has '+tail' => (
        handles => 'get',
    );

But you get a circular dependency on the role and the tail attribute.
The body role can't be consumed without the get method, and the tail attribute
can't be delegated to until the body role has been consumed.

This module is a workaround. Instead, of the above, you do this:

    package MyChain::MyBody;
    use Object::Chain::Body::AutoDelegate qw( get );
    use MyChain;
    with 'MyChain::Role::Body';

=cut
