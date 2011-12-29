package KVStore::Body::Check;

use feature 'say';

use Moose;
use namespace::autoclean;

use KVStore;

# Can't do this(?) - chicken and egg problem
#has '+tail' => (
    #handles => 'get',
#);

use Object::Chain::Body::AutoDelegate qw( get );

with 'KVStore::Role::Body';

sub set {
    my ($self, $head, $key, $value) = @_;
    print STDERR ref $head, "\n";
    $self->tail->set($head, $key, $value);
    return;
}

1;
