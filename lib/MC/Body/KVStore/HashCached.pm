package MC::Body::KVStore::HashCached;

use Moose;
use namespace::autoclean;

with 'MC::Role::Body::KVStore';

has _cache => (
    is => 'ro',
    isa => 'HashRef',
    default => sub { {} },
    init_arg => undef,
);

sub set {
    my ($self, $head, $key, $value) = @_;

    $self->_cache->{$key} = $value;
    $self->inner->set($head, $key, $value); #TODO: be lazy
    return;
}

sub get {
    my ($self, $head, $key) = @_;

    if (not exists $self->_cache->{$key}) {
        $self->_cache->{$key} = $self->inner->get($head, $key);
    }
    return $self->_cache->{$key};

}

__PACKAGE__->meta->make_immutable;
1;
