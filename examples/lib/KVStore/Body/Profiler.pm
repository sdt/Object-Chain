package KVStore::Body::Profiler;

use Moose;
use namespace::autoclean;

use KVStore;
with 'KVStore::Role::Body';

for my $attr (qw( set get )) {
    has "${attr}_count" => (
        is      => 'ro',
        isa     => 'Num',
        traits  => ['Counter'],
        default => 0,
        handles => {
            "_inc_${attr}_count" => 'inc',
            "reset_${attr}_count" => 'reset',
        },
    )
}

sub set {
    my $self = shift;

    $self->_inc_set_count;
    $self->tail->set(@_);
    return;
}

sub get {
    my $self = shift;

    $self->_inc_get_count;
    return $self->tail->get(@_);
}

__PACKAGE__->meta->make_immutable;
1;
