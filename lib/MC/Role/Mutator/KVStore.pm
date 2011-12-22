package MC::Role::Mutator::KVStore;

use Moose::Role;
use namespace::autoclean;

with 'MC::Role::Base::KVStore'; # must implement get & set

has inner => (                  # must provide an inner object to new
    is       => 'ro',
    does     => 'MC::Role::Base::KVStore',
    required => 1,
);

1;
