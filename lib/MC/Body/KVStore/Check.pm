package MC::Body::KVStore::Check;

use Moose;
use namespace::autoclean;

use KVStore;

# Can't do this(?) - chicken and egg problem
#has +inner => (
#    handles => 'get',
#);

with 'MC::Role::Body::KVStore';

sub set {
    my ($self, $head, $key, $value) = @_;
    print STDERR ref $head, "\n";
    $self->inner->set($head, $key, $value);
    return;
}

sub get {
    my ($self, $head, $key) = @_;
    return $self->inner->get($head, $key);
}
