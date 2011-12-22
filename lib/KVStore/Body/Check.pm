package KVStore::Body::Check;

use Moose;
use namespace::autoclean;

use KVStore;

# Can't do this(?) - chicken and egg problem
#has +tail => (
#    handles => 'get',
#);

with 'KVStore::Role::Body';

sub set {
    my ($self, $head, $key, $value) = @_;
    print STDERR ref $head, "\n";
    $self->tail->set($head, $key, $value);
    return;
}

sub get {
    my ($self, $head, $key) = @_;
    return $self->tail->get($head, $key);
}
