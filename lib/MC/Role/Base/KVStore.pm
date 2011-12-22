package MC::Role::Base::KVStore;

use Moose::Role;
use namespace::autoclean;

requires qw( get set );  # consuming class must implement get & set

1;
