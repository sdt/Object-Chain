package MC::Composer;

use Class::Load ':all';

my $sample = {
    type => 'KVStore',
    mc => [
        {
            name => 'Storable',
            args => qw( filename ),
        },
        {
            name => 'HashCached',
            args => [],
        },
    ],
};

sub compose {
    my ($class, %args) = @_;

    my $class = undef;

    for my ($def
}

sub _create_base {
    my ($inner, $base_class, $name, $args) = @_;

    my $class_name = "MC::Base::${base_class}::${name}";
    load_class($class_name);

    return $class_name->new(%$args);
}
