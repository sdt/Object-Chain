package KVStore::Body::Compress;

use Moose;
use namespace::autoclean;

use KVStore;
with 'KVStore::Role::Body';

use Compress::Zlib;

sub set {
    my ($self, $head, $key, $value) = @_;

    my $zvalue = Compress::Zlib::memGzip($value);
    $self->tail->set($head, $key, $zvalue);
    return;
}

sub get {
    my ($self, $head, $key) = @_;

    my $zvalue = $self->tail->get($head, $key);
    return Compress::Zlib::memGunzip($zvalue);
}

__PACKAGE__->meta->make_immutable;

1;
