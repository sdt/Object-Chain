package Object::Chain::Composer;

# ABSTRACT: Create object chains from data
# VERSION

use strict;
use warnings;

use Carp            qw( croak );
use Class::Load     qw( load_class );

sub compose {
    my ($basetype, $segments) = @_;

    my $body = undef;
    for my $segment (@$segments) {
        $body = _create_segment($basetype, $segment, $body);
    }

    my $headtype = $basetype . '::Head';
    return $headtype->new(body => $body);
}

sub _create_segment {
    my ($basetype, $taildef, $tail) = @_;

    my ($classname, %args);
    if (ref $taildef eq 'HASH') {
        croak 'Multiple chain segments'
            if keys %$taildef > 1;
        ($classname) = keys %$taildef;
        %args = %{ $taildef->{$classname} };
    }
    elsif (ref $taildef) {
        croak 'Chain definition should be hashref or string, not '
              . ref $taildef;
    }
    else {
        $classname = $taildef;
    }

    my $subtype;
    if (defined $tail) {
        $subtype = 'Body';
        $args{tail} = $tail;
    }
    else {
        $subtype = 'Tail';

    }

    my $type = join('::', $basetype, $subtype, $classname);
    load_class($type);
    $args{tail} = $tail if $tail;
    return $type->new(%args);
}

1;

__END__

=pod

=end
