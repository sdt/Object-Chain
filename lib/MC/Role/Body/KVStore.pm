package MC::Role::Body::KVStore;

use Moose::Role;
use namespace::autoclean;

with 'MC::Role::Tail::KVStore'; # must implement get & set

has inner => (                  # must provide an inner object to new
    is       => 'ro',
    does     => 'MC::Role::Tail::KVStore',
    required => 1,
);

1;
