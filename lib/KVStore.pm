package KVStore;

use MC::ClassBuilder;

BEGIN { MC::ClassBuilder::build(KVStore => qw( get set )) };

1;
