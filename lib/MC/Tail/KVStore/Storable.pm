package MC::Tail::KVStore::Storable;

use Moose;
use namespace::autoclean;

use KVStore;
with 'MC::Role::Tail::KVStore';

use Storable qw( store retrieve );

has filename => (
    is => 'ro',
    isa => 'Str',
    required => 1,
);

sub set {
    my ($self, $head, $key, $value) = @_;

    my $db = $self->_load_db();
    $db->{$key} = $value;
    store($db, $self->filename);
    return;
}

sub get {
    my ($self, $head, $key) = @_;
    my $db = $self->_load_db();
    return $db->{$key};
}

sub _load_db {
    my ($self) = @_;
    return eval { retrieve($self->filename) } // {};
    #return -f $self->filename ? retrieve($self->filename) : {};
}

__PACKAGE__->meta->make_immutable;
1;
