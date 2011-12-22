package MC::Head::KVStore;

use Moose;
use namespace::autoclean;

has body => (
    is          => 'ro',
    does        => 'MC::Role::Base::KVStore',
    required    => 1,
    handles     => [qw( get set )],
);

around [qw( get set )] => sub {
    my ($orig, $self, @args) = @_;
    $self->$orig($self, @args);
};

__PACKAGE__->meta->make_immutable;
1;
